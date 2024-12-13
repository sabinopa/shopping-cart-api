require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "GET /cart" do
    let!(:cart) { create(:cart, total_price: 30.0) }
    let!(:product1) { create(:product, price: 10.0) }
    let!(:product2) { create(:product, price: 15.0) }
    let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 2) }
    let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 1) }

    context "when there is a current cart" do
      before { allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id }) }

      it "returns the current cart with its items" do
        get "/cart", as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(cart.id)
        expect(json_response["products"].size).to eq(2)
        expect(json_response["products"][0]["id"]).to eq(product1.id)
        expect(json_response["products"][0]["quantity"]).to eq(2)
        expect(json_response["products"][0]["total_price"]).to eq(20.0)
        expect(json_response["total_price"]).to eq(30.0)
      end
    end

    context "when there is no cart" do
      before { allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: nil }) }

      it "creates a new cart" do
        expect { get "/cart", as: :json }.to change { Cart.count }.by(1)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).not_to be_nil
        expect(json_response["products"]).to be_empty
        expect(json_response["total_price"]).to eq(0.0)
      end
    end
  end

  describe "POST /cart/add_item" do
    let!(:product) { create(:product, price: 10.0) }

    context "when the cart does not exist" do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json
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
      let!(:cart) { create(:cart, total_price: 0.0) }
      let!(:product) { create(:product, price: 10.0) }
      let!(:existing_product) { create(:product, price: 15.0) }
      let!(:cart_item) { create(:cart_item, cart: cart, product: existing_product, quantity: 1) }


      before { allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id }) }

      it "adds the product to the existing cart" do
        expect {
          post '/cart/add_item', params: { product_id: product.id, quantity: 2 }, as: :json
        }.to change { cart.cart_items.count }.by(1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["total_price"]).to eq(35.0)
      end

      it "updates the quantity of the existing product" do
        expect {
          post "/cart/add_item", params: { product_id: existing_product.id, quantity: 2 }, as: :json
        }.to change { cart_item.reload.quantity }.by(2)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["products"][0]["id"]).to eq(existing_product.id)
        expect(json_response["products"][0]["quantity"]).to eq(3)
        expect(json_response["products"][0]["total_price"]).to eq(45.0)
      end
    end

    context "when the product does not exist" do
      it "returns a not found error" do
        post "/cart/add_item", params: { product_id: 9999, quantity: 2 }, as: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq('Product not found')
      end
    end

    context "when the quantity is invalid" do
      subject { post "/cart/add_item", params: { product_id: product.id, quantity: -1 }, as: :json }

      it "returns an error" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Quantity must be greater than 0")
      end

      it "returns an error for zero quantity" do
        post "/cart/add_item", params: { product_id: product.id, quantity: 0 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Quantity must be greater than 0")
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart) { create(:cart, total_price: 30.0) }
    let!(:product) { create(:product, price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    before { allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id }) }

    context "when reducing the quantity of an item" do
      it "removes the product when quantity reaches zero" do
        expect {
          delete "/cart/#{product.id}", params: { quantity: 2 }, as: :json
        }.to change { cart.reload.cart_items.count }.by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"]).to be_empty
        expect(json_response["total_price"]).to eq(0.0)
      end

      it "reduces the quantity without removing the item completely" do
        expect {
          delete "/cart/#{product.id}", params: { quantity: 1 }, as: :json
        }.to change { cart_item.reload.quantity }.by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["products"][0]["quantity"]).to eq(1)
        expect(json_response["total_price"]).to eq(10.0)
      end
    end

    context "when removing one of multiple products" do
      let!(:another_product) { create(:product, price: 5.0) }
      let!(:another_cart_item) { create(:cart_item, cart: cart, product: another_product, quantity: 1) }

      it "removes the product but keeps other products in the cart" do
        expect { delete "/cart/#{product.id}", params: { quantity: 2 }, as: :json }
          .to change { cart.reload.cart_items.count }.by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["products"][0]["id"]).to eq(another_product.id)
        expect(json_response["total_price"]).to eq(5.0)
      end
    end

    context "when the product is not in the cart" do
      it "returns an error" do
        delete "/cart/9999", params: { quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Product not in cart")
      end
    end

    context "when the cart becomes empty" do
      it "returns an empty cart payload" do
        delete "/cart/#{product.id}", params: { quantity: 2 }, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["products"]).to be_empty
        expect(json_response["total_price"]).to eq(0.0)
      end
    end
  end
end
