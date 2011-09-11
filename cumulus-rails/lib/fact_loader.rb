require 'rest_client'

class FactLoader
  def self.process!
    type     = "page_view"
    from     = "1315524514"
    to       = "1315525514"
    group    = "resource"
    property = "response_time"

    response = RestClient.get "http://localhost:4000/atoms?type=#{type}&from=#{from}&to=#{to}&property=#{property}&group=#{group}", accept: :json do |response, request, result, &block|
      if response.code == 200
        JSON.parse(response)
      else
        response.return!(request, result, &block)
      end
    end
  end
end
