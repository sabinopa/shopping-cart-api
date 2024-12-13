class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  after_save :update_cart_last_interaction
  after_destroy :update_cart_last_interaction

  private

  def update_cart_last_interaction
    cart.update!(last_interaction_at: Time.current)
  end
end
