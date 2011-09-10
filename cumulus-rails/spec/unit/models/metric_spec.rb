require 'unit_helper'

describe Metric do
  let(:table_name) { :"account_#{account.id}__metric_#{metric.id}" }
  let(:grains)     { [:foo, :bar] }
  let(:account)    { FactoryGirl.create :account }
  let(:metric)     { FactoryGirl.build :metric, id: 123, account: account, grains: grains }

  describe "#save" do
    context "when created" do
      subject { metric.save }

      it "should create the fact table" do
        expect { subject }.to change { table_exists?(table_name) }.from(false).to(true)
      end

      it "should synchronize the grain columns" do
        subject
        metric.facts_dataset.columns.should =~ Metric::FACT_COLUMNS + grains
        metric.grains.should =~ grains
      end
    end

    context "when updated with grains" do
      let(:grains) { [:foo, :baz] }

      before { metric.save! }

      subject { metric.update(grains: grains) }

      it "should synchronize the grain columns" do
        subject
        metric.facts_dataset.columns.should =~ Metric::FACT_COLUMNS + grains
        metric.grains.should =~ grains
      end
    end
  end

  describe "#destroy" do
    before { metric.save! }

    subject { metric.destroy }

    it "should drop the fact table" do
      expect { subject }.to change { table_exists?(table_name) }.from(true).to(false)
    end
  end
end
