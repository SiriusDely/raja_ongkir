require 'httparty'
require 'net/http'
require 'openssl'
require 'raja_ongkir/version'
require 'uri'

module RajaOngkir
  BASE_URL = 'https://api.rajaongkir.com'.freeze

  class Client
    include HTTParty

    base_uri BASE_URL

    def initialize(account_type = 'starter', api_key)
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
      if options.length <= 0 && q && q.is_a?(Hash)
        options = options.merge(q)
        q = nil
      elsif options.length <= 0 && q && !q.is_a?(String)
        raise 'Provided q must be a String'
      elsif !options.empty? && q && !q.is_a?(String)
        raise 'Provided q must be a String'
      end
      if @provinces.nil? || options[:reload]
        p 'reload'
        # query = id ? build_query(id: id) : build_query
        response = self.class.get("/#{@account_type}/province", build_query)
        status = response['rajaongkir']['status']
        if status['code'] >= 200 && status['code'] < 300
          @provinces = response['rajaongkir']['results']
        else
          raise "#{status['description']} CODE #{status['code']}"
        end
      end
      if q && q.is_a?(String)
        @provinces.select { |p| p['province'].downcase =~ /#{Regexp.quote(q.downcase)}/ }
      else
        @provinces
      end
    end

    def province(id, options = {})
      raise 'Provided id must be an Integer.' unless id.is_a?(Integer)
      @provinces = provinces(options)
      @provinces.find { |p| p['province_id'] == id.to_s }
    end

    def cities(q = nil, options = {})
      if options.length <= 0 && q && q.is_a?(Hash)
        options = options.merge(q)
        q = nil
      elsif options.length <= 0 && q && !q.is_a?(String)
        raise 'Provided q must be a String'
      elsif !options.empty? && !q.nil? && !q.is_a?(String)
        raise 'Provided q must be a String'
      end
      reload = options[:reload]
      if @cities.nil? || reload
        p 'reload'
        response = self.class.get("/#{@account_type}/city", build_query)
        status = response['rajaongkir']['status']
        if status['code'] >= 200 && status['code'] < 300
          @cities = response['rajaongkir']['results']
        else
          raise "#{status['description']} CODE #{status['code']}"
        end
      end
      if q && q.is_a?(String)
        @cities.select { |c| c['city_name'].downcase =~ /#{Regexp.quote(q.downcase)}/ }
      else
        @cities
      end
    end

    def city(id, options = {})
      raise 'Provided id must be an Integer.' unless id.is_a?(Integer)
      @cities = cities(options)
      @cities.find { |c| c['city_id'] == id.to_s }
    end

    private

    def build_query(query = {})
      query ||= {}
      { query: query, headers: { 'key' => @api_key } }
    end
  end
end
