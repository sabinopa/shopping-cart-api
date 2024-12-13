class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: @cart.as_json_response, status: :ok
  end

  def add_item
    product = find_product
    return unless product

    quantity = validate_quantity
    return unless quantity

    if @cart.add_item(product.id, quantity)
      render json: @cart.as_json_response, status: :ok
    else
      render json: { error: @cart.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def remove_item
    product_id = params[:product_id].to_i
    quantity_to_remove = params[:quantity].to_i

    return render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity if quantity_to_remove <= 0

    begin
      @cart.remove_item(product_id, quantity_to_remove)
      render json: @cart.as_json_response, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def find_product
    product = Product.find_by(id: params[:product_id])
    render json: { error: "Product not found" }, status: :not_found unless product
    product
  end

  def validate_quantity
    quantity = params[:quantity].to_i
    if quantity <= 0
      render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity
      return nil
    end
    quantity
  end

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
    unless @cart
      @cart = Cart.create!(total_price: 0.0)
      session[:cart_id] ||= @cart.id
    end
  end
end
