require "httparty"
require "net/http"
require "openssl"
require "raja_ongkir/version"
require "uri"

module RajaOngkir
  BASE_URL = "https://api.rajaongkir.com"

  class Client
    include HTTParty

    base_uri BASE_URL

    def initialize(account_type = "starter", api_key)
      @account_type = account_type
      @api_key = api_key
    end

    def hi
      url = URI("#{BASE_URL}/#{@account_type}/province?id=12")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request["key"] = @api_key

      response = http.request(request)
      puts response.read_body
    end

    def provinces(q = nil, options = {})
      if (options.length > 0 and not q.nil? and not q.is_a?(String)) or
          (options.length <= 0 and not q.nil? and not q.is_a?(Hash))
        raise "Provided q must be an String"
      end
      if q.is_a?(Hash)
        options = options.merge(q)
        q = nil
      end
      reload = options[:reload]
      if reload or not @provinces
        p "reload"
        # query = id ? build_query(id: id) : build_query
        response = self.class.get("/#{@account_type}/province", build_query)
        status = response["rajaongkir"]["status"]
        unless status["code"] >= 200 and status["code"] < 300
          raise "#{status["description"]} CODE #{status["code"]}"
        else
          @provinces = response["rajaongkir"]["results"]
        end
      end
      unless q and q.is_a?(String)
        @provinces
      else
        @provinces.select{ |p| p["province"].downcase =~ /#{Regexp.quote(q.downcase)}/ }
      end
    end

    def province(id, options = {})
      unless id.is_a?(Integer)
        raise "Provided id must be an Integer."
      end
      @provinces = provinces(options)
      @provinces.find{ |p| p["province_id"] == id.to_s }
    end

    def cities
      response = self.class.get("/#{@account_type}/city", headers: {"key" => @api_key})
    end

    private

    def build_query query={}
      query ||= {}
      {query: query, headers: {"key" => @api_key}}
    end
  end
end
