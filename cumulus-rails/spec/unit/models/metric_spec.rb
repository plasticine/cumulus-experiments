require 'unit_helper'

describe Metric do
  let(:account) { FactoryGirl.create(:account) }
  let(:metric)  { FactoryGirl.create(:metric, account: account) }

  describe "#fact_table_name" do
    subject { metric.fact_table_name }

    it { should == :"account_#{account.id}__metric_#{metric.id}" }
  end

  describe "#save" do
    context "when created" do
      let(:metric) { FactoryGirl.build(:metric, id: 123, account: account) }

      it "should create the fact table" do
        expect { metric.save }.to change { table_exists?(metric.fact_table_name) }.from(false).to(true)
      end

      it "should synchronize the property columns" do
        metric.save
        metric.facts_dataset.columns.should =~ Metric::FACT_COLUMNS + metric.grain_columns + metric.property_columns
      end
    end

    context "when updated" do
      before { metric.properties = [:lorem, :dolor] }

      it "should synchronize the property columns" do
        metric.save
        metric.facts_dataset.columns.should =~ Metric::FACT_COLUMNS + metric.grain_columns + metric.property_columns
      end
    end
  end

  describe "#destroy" do
    it "should drop the fact table" do
      expect { metric.destroy }.to change { table_exists?(metric.fact_table_name) }.from(true).to(false)
    end
  end

  describe "#aggregate" do
    let(:resolution) { :hour }

    before do
      Timecop.freeze(Time.zone.parse("2011-01-01 02:00")) do
        1.upto(240) do |n|
          metric.facts_dataset.insert(
            timestamp: n.minutes.ago,
            sum_lorem: n * 1,
            avg_lorem: n * 2,
            min_lorem: n * 3,
            max_lorem: n * 4,
            sum_ipsum: n * 5,
            avg_ipsum: n * 6,
            min_ipsum: n * 7,
            max_ipsum: n * 8,
            count:     n * 10
          )
        end
      end
    end

    subject(:results) { metric.aggregate(resolution).all }

    context "by year" do
      let(:resolution) { :year }

      its(:length) { should == 2 }

      context "first result" do
        subject { results.first.to_ostruct }

        its(:timestamp) { should == Time.zone.parse("2010-01-01 00:00") }
        its(:count)     { should == 216600 }
        its(:sum_lorem) { should == 21660 }
        its(:avg_lorem) { should == 361 }
        its(:min_lorem) { should == 363 }
        its(:max_lorem) { should == 960 }
      end

      context "last result" do
        subject { results.last.to_ostruct }

        its(:timestamp) { should == Time.zone.parse("2011-01-01 00:00") }
        its(:count)     { should == 72600 }
        its(:sum_lorem) { should == 7260 }
        its(:avg_lorem) { should == 121 }
        its(:min_lorem) { should == 3 }
        its(:max_lorem) { should == 480 }
      end
    end

     context "by month" do
       let(:resolution) { :month }

       its(:length) { should == 2 }

       context "first result" do
         subject { results.first.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2010-12-01 00:00") }
         its(:count)     { should == 216600 }
         its(:sum_lorem) { should == 21660 }
         its(:avg_lorem) { should == 361 }
         its(:min_lorem) { should == 363 }
         its(:max_lorem) { should == 960 }
       end

       context "last result" do
         subject { results.last.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2011-01-01 00:00") }
         its(:count)     { should == 72600 }
         its(:sum_lorem) { should == 7260 }
         its(:avg_lorem) { should == 121 }
         its(:min_lorem) { should == 3 }
         its(:max_lorem) { should == 480 }
       end
     end

     context "by day" do
       let(:resolution) { :day }

       its(:length) { should == 2 }

       context "first result" do
         subject { results.first.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2010-12-31 00:00") }
         its(:count)     { should == 216600 }
         its(:sum_lorem) { should == 21660 }
         its(:avg_lorem) { should == 361 }
         its(:min_lorem) { should == 363 }
         its(:max_lorem) { should == 960 }
       end

       context "last result" do
         subject { results.last.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2011-01-01 00:00") }
         its(:count)     { should == 72600 }
         its(:sum_lorem) { should == 7260 }
         its(:avg_lorem) { should == 121 }
         its(:min_lorem) { should == 3 }
         its(:max_lorem) { should == 480 }
       end
     end

     context "by hour" do
       let(:resolution) { :hour }

       its(:length) { should == 4 }

       context "first result" do
         subject { results.first.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2010-12-31 22:00") }
         its(:count)     { should == 126300 }
         its(:sum_lorem) { should == 12630 }
         its(:avg_lorem) { should == 421 }
         its(:min_lorem) { should == 543 }
         its(:max_lorem) { should == 960 }
       end

       context "last result" do
         subject { results.last.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2011-01-01 01:00") }
         its(:count)     { should == 18300 }
         its(:sum_lorem) { should == 1830 }
         its(:avg_lorem) { should == 61 }
         its(:min_lorem) { should == 3 }
         its(:max_lorem) { should == 240 }
       end
     end

     context "by minute" do
       let(:resolution) { :minute }

       its(:length) { should == 240 }

       context "first result" do
         subject { results.first.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2010-12-31 22:00") }
         its(:count)     { should == 2400 }
         its(:sum_lorem) { should == 240 }
         its(:avg_lorem) { should == 480 }
         its(:min_lorem) { should == 720 }
         its(:max_lorem) { should == 960 }
       end

       context "last result" do
         subject { results.last.to_ostruct }

         its(:timestamp) { should == Time.zone.parse("2011-01-01 01:59") }
         its(:count)     { should == 10 }
         its(:sum_lorem) { should == 1 }
         its(:avg_lorem) { should == 2 }
         its(:min_lorem) { should == 3 }
         its(:max_lorem) { should == 4 }
       end
     end

     context "with an invalid resolution" do
       let(:resolution) { :foo }

       it "should raise an error" do
         expect { results }.to raise_error("invalid resolution 'foo'")
       end
     end
  end
end
