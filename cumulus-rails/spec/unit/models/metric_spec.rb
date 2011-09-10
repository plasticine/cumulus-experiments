require 'unit_helper'

describe Metric do
  let(:account) { FactoryGirl.create :account }
  let(:metric)  { FactoryGirl.create :metric, account: account }

  describe "#fact_table_name" do
    subject { metric.fact_table_name }
    it { should == :"account_#{account.id}__metric_#{metric.id}" }
  end

  describe "#save" do
    subject { metric.save }

    context "when created" do
      let(:metric) { FactoryGirl.build :metric, id: 123, account: account }

      it "should create the fact table" do
        expect { subject }.to change { table_exists?(metric.fact_table_name) }.from(false).to(true)
      end

      it "should synchronize the grain columns" do
        subject
        metric.facts_dataset.columns.should =~ Metric::FACT_COLUMNS + metric.grains
      end
    end

    context "when updated" do
      before { metric.grains = [:foo, :baz] }

      it "should synchronize the grain columns" do
        subject
        metric.facts_dataset.columns.should =~ Metric::FACT_COLUMNS + metric.grains
      end
    end
  end

  describe "#destroy" do
    subject { metric.destroy }

    it "should drop the fact table" do
      expect { subject }.to change { table_exists?(metric.fact_table_name) }.from(true).to(false)
    end
  end

  describe "#aggregate" do
    let(:resolution) { :hour }
    let(:function)   { :avg }
    let(:results)    { metric.aggregate(resolution, function).all }

    before do
      Timecop.freeze("2011-01-01 02:00".to_time) do
        1.upto(240) do |n|
          metric.facts_dataset.insert(timestamp: n.minutes.ago, value: n)
        end
      end
    end

    subject { results }

    context "by year" do
      let(:resolution) { :year }

      its(:length) { should == 2 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-01-01 00:00".to_time }
        its(:value)     { should == 180.5 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 00:00".to_time }
        its(:value)     { should == 60.5 }
      end
    end

    context "by month" do
      let(:resolution) { :month }

      its(:length) { should == 2 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-01 00:00".to_time }
        its(:value)     { should == 180.5 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 00:00".to_time }
        its(:value)     { should == 60.5 }
      end
    end

    context "by week" do
      let(:resolution) { :week }

      its(:length) { should == 1 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-27 00:00".to_time }
        its(:value)     { should == 120.5 }
      end
    end

    context "by day" do
      let(:resolution) { :day }

      its(:length) { should == 2 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 00:00".to_time }
        its(:value)     { should == 180.5 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 00:00".to_time }
        its(:value)     { should == 60.5 }
      end
    end

    context "by hour" do
      let(:resolution) { :hour }

      its(:length) { should == 4 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 22:00".to_time }
        its(:value)     { should == 210.5 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 01:00".to_time }
        its(:value)     { should == 30.5 }
      end
    end

    context "by half-hour" do
      let(:resolution) { :half_hour }

      its(:length) { should == 8 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 22:00".to_time }
        its(:value)     { should == 225.5 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 01:30".to_time }
        its(:value)     { should == 15.5 }
      end
    end

    context "by quarter-hour" do
      let(:resolution) { :quarter_hour }

      its(:length) { should == 16 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 22:00".to_time }
        its(:value)     { should == 233 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 01:45".to_time }
        its(:value)     { should == 8 }
      end
    end

    context "by sixth-hour" do
      let(:resolution) { :sixth_hour }

      its(:length) { should == 24 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 22:00".to_time }
        its(:value)     { should == 235.5 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 01:50".to_time }
        its(:value)     { should == 5.5 }
      end
    end

    context "by twelfth-hour" do
      let(:resolution) { :twelfth_hour }

      its(:length) { should == 48 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 22:00".to_time }
        its(:value)     { should == 238 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 01:55".to_time }
        its(:value)     { should == 3 }
      end
    end

    context "by minute" do
      let(:resolution) { :minute }

      its(:length) { should == 240 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == "2010-12-31 22:00".to_time }
        its(:value)     { should == 240 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == "2011-01-01 01:59".to_time }
        its(:value)     { should == 1 }
      end
    end

    context "with an invalid resolution" do
      let(:resolution) { :foo }

      it "should raise an error" do
        expect { subject }.to raise_error("invalid resolution 'foo'")
      end
    end

    context "with an invalid function" do
      let(:function) { :foo }

      it "should raise an error" do
        expect { subject }.to raise_error("invalid function 'foo'")
      end
    end
  end
end
