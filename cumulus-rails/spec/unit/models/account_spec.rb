require 'unit_helper'

describe Account do
  let(:schema_name) { :"account_#{account.id}" }
  let(:account)     { FactoryGirl.create(:account) }

  context "#save" do
    context "when created" do
      let(:account) { FactoryGirl.build(:account, id: 123) }

      it "should create an API key" do
        expect { account.save }.to change(account, :api_key).from(nil)
        account.api_key.should =~ /[a-z0-9]{16}/
      end

      it "should create the account schema" do
        expect { account.save }.to change { schema_exists?(schema_name) }.from(false).to(true)
      end
    end

    context "when updated" do
      it "should not change the API key" do
        expect { account.save }.not_to change(account, :api_key)
      end
    end
  end

  describe "#destroy" do
    it "should drop the account schema" do
      expect { account.destroy }.to change { schema_exists?(schema_name) }.from(true).to(false)
    end
  end
end
