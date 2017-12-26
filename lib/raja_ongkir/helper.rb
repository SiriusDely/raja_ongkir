module RajaOngkir
  ## Helper for RajaOngkir::Client
  #
  class Helper
    def self.sanitize_costs_params(origin_id, destination_id, grams, courier)
      origin_id = origin_id.to_i
      destination_id = destination_id.to_i
      grams = grams.to_i
      raise 'origin_id, destination_id, and grams must be a positive Integer' if
      origin_id <= 0 || destination_id <= 0 || grams <= 0
      [origin_id, destination_id, grams, courier]
    end

    def self.build_costs_query(origin_id, destination_id, grams, courier)
      {
        headers: {
          'key' => api_key,
          'content-type' => 'application/x-www-form-urlencoded'
        },
        body: "origin=#{origin_id}&destination=#{destination_id}&" \
        "weight=#{grams}&courier=#{courier}"
      }
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def self.sanitize_params(q, options)
      return [nil, options.merge(q)] if
      options.length <= 0 && q && q.is_a?(Hash)
      raise 'Provided q must be a String' if
      (options.length <= 0 && q && !q.is_a?(String)) ||
      (!options.empty? && !q.nil? && !q.is_a?(String))

      [q, options]
    end
    # rubocop:enable all

    class << self
      attr_accessor :api_key

      def build_query(query = {})
        query ||= {}
        { query: query, headers: { 'key' => api_key } }
      end

      def items_from_resp(response)
        status = response['rajaongkir']['status']
        items = response['rajaongkir']['results']
        return items if status['code'] >= 200 && status['code'] < 300
        raise "#{status['description']} CODE #{status['code']}"
      end

      def filter_by_keyword(items, q)
        item = items.first
        if item['city_name']
          key = 'city_name'
        elsif item['province']
          key = 'province'
        end
        items.select do |p|
          p[key].downcase =~ /#{Regexp.quote(q.downcase)}/
        end
      end
    end
  end
end
