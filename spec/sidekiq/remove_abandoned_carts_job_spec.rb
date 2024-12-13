RSpec.describe RemoveAbandonedCartsJob, type: :job do

  let!(:old_abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 8.days.ago) }
  let!(:recent_abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 6.days.ago) }
  let!(:active_cart) { create(:cart, status: :active, last_interaction_at: 2.days.ago) }

  it "removes carts that have been abandoned for more than 7 days" do
    expect { RemoveAbandonedCartsJob.new.perform }.to change { Cart.count }.by(-1)

    expect(Cart.exists?(old_abandoned_cart.id)).to be false
    expect(Cart.exists?(recent_abandoned_cart.id)).to be true
    expect(Cart.exists?(active_cart.id)).to be true
  end
end
