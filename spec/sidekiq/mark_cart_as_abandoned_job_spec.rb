require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let!(:active_cart) { create(:cart, last_interaction_at: 2.hours.ago, status: :active)}
  let!(:inactive_cart) { create(:cart, last_interaction_at: 4.hours.ago, status: :active)}

  it "marks inactive carts as abandoned" do
    expect { MarkCartAsAbandonedJob.new.perform }.to change { Cart.where(status: :abandoned).count }.by(1)

    expect(inactive_cart.reload.abandoned?).to be true
    expect(active_cart.reload.abandoned?).to be false
  end
end
