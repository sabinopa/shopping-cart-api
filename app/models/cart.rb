class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  enum status: { active: 0, abandoned: 1 }

  def add_product(product_id, quantity)
    product = Product.find(product_id)
    cart_item = cart_items.find_or_initialize_by(product_id: product.id)
    cart_item.quantity += quantity
    cart_item.save!

    self.total_price = cart_items.sum { |item| item.quantity * item.product.price }
    save!
  end

  def mark_as_abandoned
    return unless last_interaction_at && last_interaction_at <= 3.hours.ago
    update!(status: :abandoned)
  end

  def remove_if_abandoned
    destroy if abandoned? && last_interaction_at <= 7.days.ago
  end
end
