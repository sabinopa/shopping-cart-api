FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { 10.0 }
  end
end
