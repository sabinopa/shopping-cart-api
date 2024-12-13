FactoryBot.define do
  factory :cart_item do
    product
    cart
    quantity { 2 }
  end
end
