require 'rest_client'

class FactLoader
  def self.process!
    type = "page_view"
    from = "1314412800"
    to   = "1314412920"

    response = RestClient.get "http://localhost:4000/atoms?type=#{type}&from=#{from}&to=#{to}", accept: :json do |response, request, result, &block|
      if response.code == 200
        JSON.parse(response)
      else
        response.return!(request, result, &block)
      end
    end
  end
end
