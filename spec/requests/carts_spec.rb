require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let!(:product) { create(:product, price: 10.0) }

  describe "POST /cart" do
    context "when the cart does not exist" do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it "creates a new cart and adds the product" do
        expect { subject }.to change { Cart.count }.by(1)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["total_price"]).to eq(20.0)
      end
    end

    context "when the cart already exists" do
      let!(:cart) { create(:cart) }

      before { allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id }) }

      it "adds the product to the existing cart" do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        }.to change { cart.cart_items.count }.by(1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["total_price"]).to eq(20.0)
      end
    end

    context "when the product does not exist" do
      it "returns a not found error" do
        post '/cart', params: { product_id: 9999, quantity: 2 }, as: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq('Product not found')
      end
    end

    context "when the quantity is invalid" do
      subject { post "/cart", params: { product_id: product.id, quantity: -1 }, as: :json }

      it "returns an error" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Quantity must be greater than 0")
      end
    end
  end

  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
