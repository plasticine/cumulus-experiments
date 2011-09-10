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
      %q([{"timestamp":1315524600,"resource":"index","sum":38871,"avg":107.37845303867404,"min":1,"max":258,"count":362},{"timestamp":1315524660,"resource":"index","sum":111580,"avg":398.5,"min":259,"max":538,"count":280}])
    end

    let(:results) { FactLoader.process! }

    before do
      stub_request(:get, "http://localhost:4000/atoms")
        .with(query: query)
        .to_return(body: body)
    end

    context "first result" do
      subject { results.first.to_ostruct }

      its(:timestamp) { should == 1315524600 }
      its(:resource)  { should == "index" }
      its(:sum)       { should == 38871 }
      its(:avg)       { should == 107.37845303867404 }
      its(:min)       { should == 1 }
      its(:max)       { should == 258 }
      its(:count)     { should == 362 }
    end

    context "last result" do
      subject { results.last.to_ostruct }

      its(:timestamp) { should == 1315524660 }
      its(:resource)  { should == "index" }
      its(:sum)       { should == 111580 }
      its(:avg)       { should == 398.5 }
      its(:min)       { should == 259 }
      its(:max)       { should == 538 }
      its(:count)     { should == 280 }
    end
  end
end
