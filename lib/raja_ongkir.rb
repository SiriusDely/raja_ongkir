require 'httparty'
require 'net/http'
require 'openssl'
require 'raja_ongkir/version'
require 'uri'

module RajaOngkir
  BASE_URL = 'https://api.rajaongkir.com'.freeze

  ## Client for rajaongkir.com
  #
  class Client
    include HTTParty

    base_uri BASE_URL

    def initialize(api_key, account_type = 'starter')
      @account_type = account_type
      @api_key = api_key
    end

    def hi
      url = URI("#{BASE_URL}/#{@account_type}/province?id=12")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['key'] = @api_key

      response = http.request(request)
      puts response.read_body
    end

    def provinces(q = nil, options = {})
      q, options = sanitize_params q, options
      if @provinces.nil? || options[:reload]
        # query = id ? build_query(id: id) : build_query
        response = self.class.get("/#{@account_type}/province", build_query)
        @provinces = items_from_resp response
      end
      return filter_by_keyword @provinces, q if q && q.is_a?(String)
      @provinces
    end

    def province(id, options = {})
      raise 'Provided id must be an Integer.' unless id.is_a?(Integer)
      @provinces = provinces(options)
      @provinces.find { |p| p['province_id'] == id.to_s }
    end

    def cities(q = nil, options = {})
      q, options = sanitize_params q, options
      reload = options[:reload]
      if @cities.nil? || reload
        response = self.class.get("/#{@account_type}/city", build_query)
        @cities = items_from_resp response
      end
      return filter_by_keyword @cities, q if q && q.is_a?(String)
      @cities
    end

    def city(id, options = {})
      raise 'Provided id must be an Integer.' unless id.is_a?(Integer)
      @cities = cities(options)
      @cities.find { |c| c['city_id'] == id.to_s }
    end

    private

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def sanitize_params(q, options)
      return [nil, options.merge(q)] if
        options.length <= 0 && q && q.is_a?(Hash)
      raise 'Provided q must be a String' if
        (options.length <= 0 && q && !q.is_a?(String)) ||
        (!options.empty? && !q.nil? && !q.is_a?(String))

      [q, options]
    end
    # rubocop:enable all

    def build_query(query = {})
      query ||= {}
      { query: query, headers: { 'key' => @api_key } }
    end

    def items_from_resp(response)
      status = response['rajaongkir']['status']
      items = response['rajaongkir']['results']
      return items if status['code'] >= 200 && status['code'] < 300
      raise "#{status['description']} CODE #{status['code']}"
    end

    def filter_by_keyword(items, q)
      item = items.first
      if item['province']
        key = 'province'
      elsif item['city_name']
        key = 'city_name'
      end
      items.select do |p|
        p[key].downcase =~ /#{Regexp.quote(q.downcase)}/
      end
    end
  end
end
