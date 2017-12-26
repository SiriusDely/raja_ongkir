require 'httparty'
require 'net/http'
require 'openssl'
require 'raja_ongkir/helper'
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
      Helper.api_key = api_key
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
      q, options = Helper.sanitize_params q, options
      if @provinces.nil? || options[:reload]
        # query = id ? build_query(id: id) : build_query
        response = self.class.get("/#{@account_type}/province",
                                  Helper.build_query)
        @provinces = Helper.items_from_resp response
      end
      return Helper.filter_by_keyword @provinces, q if q && q.is_a?(String)
      @provinces
    end

    def province(id, options = {})
      raise 'Provided id must be an Integer.' unless id.is_a?(Integer)
      @provinces = provinces(options)
      @provinces.find { |p| p['province_id'] == id.to_s }
    end

    def cities(q = nil, options = {})
      q, options = Helper.sanitize_params q, options
      reload = options[:reload]
      if @cities.nil? || reload
        response = self.class.get("/#{@account_type}/city", Helper.build_query)
        @cities = Helper.items_from_resp response
      end
      return Helper.filter_by_keyword @cities, q if q && q.is_a?(String)
      @cities
    end

    def city(id, options = {})
      raise 'Provided id must be an Integer.' unless id.is_a?(Integer)
      @cities = cities(options)
      @cities.find { |c| c['city_id'] == id.to_s }
    end

    def costs(origin_id, destination_id, grams, courier = 'jne')
      origin_id, destination_id, grams, courier =
        Helper.sanitize_costs_params origin_id, destination_id, grams, courier
      response = self.class.post(
        "/#{@account_type}/cost",
        Helper.build_costs_query(origin_id, destination_id, grams, courier)
      )
      @costs = Helper.items_from_resp response
    end
  end
end
