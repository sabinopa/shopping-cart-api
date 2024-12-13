class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def add_product(product_id, quantity)
    product = Product.find(product_id)
    cart_item = cart_items.find_or_initialize_by(product_id: product.id)
    cart_item.quantity += quantity
    cart_item.save!

    self.total_price = cart_items.sum { |item| item.quantity * item.product.price }
    save!
  end
end
