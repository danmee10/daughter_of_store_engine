class CheckoutsController < ApplicationController
  before_filter :require_login, only: [ :buy_now ]
  before_filter :build_user

  def show
  end

  def create
    if @user.save
      order = create_order(@user, current_cart)

      if order.valid?
        @cart_calculator = CartsController::CartCalculator.new(current_cart,current_discount)

        # order should store the amount of savings
        flash[:post_order_discount] = @cart_calculator.savings

        session[:discount_id] = nil
        current_cart.destroy

        redirect_to order_path(order), notice: "Order submitted!"
      else
        redirect_to store_cart_path(current_store), notice: "Checkout failed."
      end
    else
      render action: :show
    end
  end

  def buy_now
    cart = Cart.new(params[:product_id] => '1')

    order = create_order(current_user, cart.items)
    if order.valid?
      redirect_to order_path(order), notice: "Order submitted!"
    else
      redirect_to :back, notice: "Checkout failed."
    end
  end

private

  def build_user
    @user = if logged_in?
      current_user.attributes = params[:user]
      current_user
    else
      User.new_guest(params[:user])
    end

    @user.build_shipping_address if @user.shipping_address.nil?
    @user.build_billing_address if @user.billing_address.nil?
  end

  def current_discount
    db_discount = Discount.find_by_id(session[:discount_id])
    Discount.convert_to_discount_object(db_discount)
  end

  def create_order(user, cart_items)
      Order.create_pending_order(user, cart_items, current_discount).tap do |order|
        Resque.enqueue(OrderConfirmEmailJob, user, order.id, order.total)
    end
  end
end
