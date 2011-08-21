$: << 'lib'

require 'rubygems'
require 'bundler/setup'
require 'goliath'
require 'models'

class Cumulus < Goliath::API
  use Goliath::Rack::DefaultMimeType
  use Goliath::Rack::Heartbeat
  use Goliath::Rack::Params
  use Goliath::Rack::Render, 'json'

  get "/accounts/:id" do
    run Proc.new {|env|
      account = Account.find(params[:id])

      if account
        [200, {}, account.to_json]
      else
        [404, {}, ""]
      end
    }
  end

  post "/accounts" do
    run Proc.new {|env|
      account = Account.new(:name => params[:name])

      if account.save
        [200, {}, account.key]
      else
        [422, {}, account.errors]
      end
    }
  end

  get "/facts/:id" do
    run Proc.new {|env|
      fact = Fact.find(params[:id])

      if fact
        [200, {}, fact.to_json]
      else
        [404, {}, ""]
      end
    }
  end

  post "/facts" do
    run Proc.new {|env|
      fact = Fact.new(
        :type       => params[:type],
        :properties => params[:properties]
      )

      if fact.save
        [200, {}, fact.key]
      else
        [422, {}, fact.errors]
      end
    }
  end

  get "/metrics/:fact_type" do
    run Proc.new {|env| [200, {}, ""] }
  end

  not_found "/" do
    run Proc.new {|env| [404, {}, ""] }
  end
end
