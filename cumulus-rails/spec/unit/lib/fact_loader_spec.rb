require 'unit_helper'

describe FactLoader do
  describe ".process!" do
    let(:query) do
      {
        type:  "page_view",
        from:  "1315524514",
        to:    "1315525514",
        group: "resource"
      }
    end

    let(:body) do
      %q([{"timestamp":1315524600,"resource":"index","sum_response_time":38871,"avg_response_time":107.37845303867404,"min_response_time":1,"max_response_time":258,"count":362},{"timestamp":1315524660,"resource":"index","sum_response_time":111580,"avg_response_time":398.5,"min_response_time":259,"max_response_time":538,"count":280}])
    end

    let(:results) { FactLoader.process! }

    before do
      stub_request(:get, "http://localhost:4000/atoms")
        .with(query: query)
        .to_return(body: body)
    end

    context "first result" do
      subject { results.first.to_ostruct }

      its(:timestamp)         { should == 1315524600 }
      its(:resource)          { should == "index" }
      its(:sum_response_time) { should == 38871 }
      its(:avg_response_time) { should == 107.37845303867404 }
      its(:min_response_time) { should == 1 }
      its(:max_response_time) { should == 258 }
      its(:count)             { should == 362 }
    end

    context "last result" do
      subject { results.last.to_ostruct }

      its(:timestamp)         { should == 1315524660 }
      its(:resource)          { should == "index" }
      its(:sum_response_time) { should == 111580 }
      its(:avg_response_time) { should == 398.5 }
      its(:min_response_time) { should == 259 }
      its(:max_response_time) { should == 538 }
      its(:count)             { should == 280 }
    end
  end
end
