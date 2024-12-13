require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe "#add_product" do
    let!(:product) { create(:product, price: 10.0)}
    let!(:cart) { create(:cart, total_price: 0)}

    context "when adding a valid product" do
      it "adds the product to the cart" do
        expect { cart.add_product(product.id, 2) }.to change { cart.cart_items.count }.by(1)
        expect(cart.total_price).to eq(20.0)
      end
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
