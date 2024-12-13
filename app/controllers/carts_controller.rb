class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: cart_response(@cart), status: :ok
  end

  def add_item
    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    quantity = params[:quantity].to_i
    return render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity if quantity <= 0

    if @cart.add_product(product.id, quantity)
      render json: cart_response(@cart), status: :ok
    else
      render json: { error: @cart.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def remove_item
    product_id = params[:product_id].to_i
    quantity_to_remove = params[:quantity].to_i

    return render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity if quantity_to_remove <= 0

    cart_item = @cart.cart_items.find_by(product_id: product_id)

    unless cart_item
      return render json: { error: "Product not in cart" }, status: :not_found
    end

    if cart_item.quantity > quantity_to_remove
      cart_item.update!(quantity: cart_item.quantity - quantity_to_remove)
    else
      cart_item.destroy!
    end

    @cart.update!(total_price: @cart.cart_items.sum { |item| item.quantity * item.product.price })

    render json: cart_response(@cart), status: :ok
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
    unless @cart
      @cart = Cart.create!(total_price: 0.0)
      session[:cart_id] ||= @cart.id
    end
  end

  def cart_response(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: (item.product.price * item.quantity).to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
