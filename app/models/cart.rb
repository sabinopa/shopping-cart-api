class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  enum status: { active: 0, abandoned: 1 }

  scope :inactive_since, ->(time_ago) { where('last_interaction_at <= ?', time_ago) }
  scope :abandoned_for, ->(time_ago) { abandoned.inactive_since(time_ago) }
  scope :active_for, ->(time_ago) { active.inactive_since(time_ago) }

  def add_item(product_id, quantity)
    cart_item = find_or_initialize_cart_item(product_id)
    cart_item.increment_quantity(quantity)
    recalculate_total_price
  end

  def remove_item(product_id, quantity_to_remove)
    cart_item = cart_items.find_by(product_id: product_id)
    raise ActiveRecord::RecordNotFound, "Product not in cart" unless cart_item

    if cart_item.quantity > quantity_to_remove
      cart_item.update!(quantity: cart_item.quantity - quantity_to_remove)
    else
      cart_item.destroy!
    end

    recalculate_total_price
  end

  def mark_as_abandoned
    update!(status: :abandoned)
  end

  def remove_if_expired
    destroy!
  end

  def as_json_response
    {
      id: id,
      products: cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: (item.product.price * item.quantity).to_f
        }
      end,
      total_price: total_price.to_f
    }
  end

  private

  def find_or_initialize_cart_item(product_id)
    product = Product.find(product_id)
    cart_items.find_or_initialize_by(product_id: product.id)
  end

  def recalculate_total_price
    self.total_price = cart_items.sum { |item| item.quantity * item.product.price }
    save!
  end
end
