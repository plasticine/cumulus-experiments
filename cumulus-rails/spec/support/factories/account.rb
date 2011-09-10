FactoryGirl.define do
  factory :account do
    name { Faker::Lorem.words(1).first }
  end
end
