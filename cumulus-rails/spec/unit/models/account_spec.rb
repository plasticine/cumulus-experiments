require 'unit_helper'

describe Account do
  let(:schema_name) { :"account_#{account.id}" }
  let(:account)     { FactoryGirl.build :account, id: 123 }

  context "#save" do
    subject { account.save }

    its(:api_key) { should =~ /[a-z0-9]{16}/ }

    it "should create the account schema" do
      expect { subject }.to change { schema_exists?(schema_name) }.from(false).to(true)
    end
  end

  describe "#destroy" do
    before { account.save! }

    subject { account.destroy }

    it "should drop the account schema" do
      expect { subject }.to change { schema_exists?(schema_name) }.from(true).to(false)
    end
  end
end
