FactoryGirl.define do
  factory :metric do
    account
    type { Faker::Lorem.words(1).first }
    grains [:foo, :bar]
    properties [:lorem, :ipsum]
  end
end
