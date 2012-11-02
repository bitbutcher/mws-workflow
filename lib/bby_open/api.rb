require 'faraday'
require 'faraday_middleware'

module BbyOpen

  class Api

    class QueryFailed < StandardError; end
    class BadRequest < StandardError; end

    def initialize(key, url='http://api.remix.bestbuy.com')
      @conn = Faraday.new(url: url, params: { apiKey: key }) do |c|
        c.use Faraday::Request::Retry
        c.use FaradayMiddleware::FollowRedirects
        c.use FaradayMiddleware::ParseJson, :content_type => /\b(json|x-javascript)$/
        c.adapter :net_http
      end
    end

    def get_sku(sku, opts = {})
      response = @conn.get("/v1/products/#{sku}.json", show: "all")
      self.class.check_response(response)
      response.body
    end

    def self.check_response(response)
      if response.body["error"]
        raise QueryFailed, response.body["error"]["message"]
      end
      if response.status != 200
        raise BadRequest, "body: #{response.body}\n\nheaders: #{response.headers}"
      end
    end

  end

end