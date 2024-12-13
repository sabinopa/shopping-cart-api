require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe "#add_item" do
    let!(:product) { create(:product, price: 10.0)}
    let!(:cart) { create(:cart, total_price: 0)}

    context "when adding a valid product" do
      it "adds the product to the cart" do
        expect { cart.add_item(product.id, 2) }.to change { cart.cart_items.count }.by(1)
        expect(cart.total_price).to eq(20.0)
      end
    end
  end

  describe 'mark_as_abandoned' do
    let(:cart) { create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      cart.update(last_interaction_at: 3.hours.ago)
      expect { cart.mark_as_abandoned }.to change { cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_expired' do
    let(:cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      cart.mark_as_abandoned
      expect { cart.remove_if_expired }.to change { Cart.count }.by(-1)
    end
  end

  describe '#last_interaction_at' do
    let!(:cart) { create(:cart, last_interaction_at: 1.day.ago) }
    let!(:product) { create(:product, price: 10.0) }

    it 'updates last_interaction_at when a product is added' do
      expect {
        cart.add_item(product.id, 1)
      }.to change { cart.last_interaction_at }
    end

    it 'updates last_interaction_at when a product is removed' do
      cart.add_item(product.id, 1)
      expect {
        cart.cart_items.first.destroy!
      }.to change { cart.last_interaction_at }
    end

    it 'updates last_interaction_at when a product quantity is updated' do
      cart.add_item(product.id, 1)
      expect {
        cart.cart_items.first.update!(quantity: 3)
      }.to change { cart.last_interaction_at }
    end
  end
end
