class PagesController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :set_fb_user, :set_msg_hash

  def home
  end

  def list_business
    # Finalize any outstanding orders
    if Order.check_outstanding(@fb_user)
      list_data = {
        text: "Please pay an outstanding order from #{Order.last_order(@fb_user).business_name}:",
        buttons: [
          {
            "button_title": "Finalize Order",
            "url_data": {
              next_action: "find_total",
              fb_user: @fb_user
            }
          }
        ]
      }

      @msg[:messages] << JsonFormatter.generate_simple_list(list_data)
    else
      @msg[:messages] << JsonFormatter.display_business_list(@fb_user)
    end

    respond_to do |format|
      format.json  { render :json => @msg }
    end
  end

  def create_order
    business_id = params[:business_id]
    order = Order.new :user_id => business_id, :fb_user => @fb_user, :business_name => User.find(business_id).name

    list_data = {
      text: "Welcome to #{order.business_name}!",
      buttons: [
        {
          "button_title": "Continue",
          "url_data": {
            next_action: "main_menu",
            fb_user: @fb_user,
            other_params: "&business_id=#{business_id}"
          }
        }
      ]
    }

    @msg[:messages] << JsonFormatter.generate_simple_list(list_data)

    respond_to do |format|
      if order.save
        format.json { render :json => @msg }
      else
        # insert error handling
      end
    end
  end

  def main_menu
    business_id = params[:business_id]

    list_data = {
      text: "Please choose from the following options:",
      buttons: [
        {
          "button_title": "Order",
          "url_data": {
            next_action: "list_categories",
            fb_user: @fb_user,
            other_params: "&business_id=#{business_id}"
          }
        },
        {
          "button_title": "Checkout",
          "url_data": {
            next_action: "find_total",
            fb_user: @fb_user,
            other_params: "&business_id=#{business_id}"
          }
        }
      ]
    }

    @msg[:messages] << JsonFormatter.generate_simple_list(list_data)

    respond_to do |format|
      format.json { render :json => @msg }
    end
  end

  def list_categories
    business_id = params[:business_id]

    @msg[:messages] << JsonFormatter.generate_categories_list(@fb_user, business_id)

    respond_to do |format|
      format.json  { render :json => @msg }
    end
  end

  def list_items
    business_id = params[:business_id]
    category_id = params[:category_id]

    @msg[:messages] << JsonFormatter.generate_items_list(@fb_user, business_id, category_id)

    respond_to do |format|
      format.json  { render :json => @msg }
    end
  end

  def add_item
    business_id = params[:business_id]
    item = params[:item]
    order = Order.last_order(@fb_user)

    order_list = order.order_list
    order_list << item
    order.update_attribute("order_list", order_list)

    @msg[:messages] << JsonFormatter.generate_message("You have ordered: #{MenuItem.find(item).name} x 1")
    @msg[:messages] << JsonFormatter.generate_categories_list(@fb_user, business_id)

    respond_to do |format|
      format.json  { render :json => @msg }
    end
  end

  def find_total
    business_id = params[:business_id]
    order = Order.last_order(@fb_user)
    order_total = order.calculate_total

    @msg[:messages] << JsonFormatter.generate_message("You ordered the following items:")

    order.order_list.each do |item|
      @msg[:messages] << JsonFormatter.generate_message("#{MenuItem.find(item).name}...$#{MenuItem.find(item).price}")
    end

    list_data = {
      text: "The total for your order is $#{order_total.round(2)}",
      buttons: [
        {
          "button_title": "Make Payment",
          "url_data": {
            next_action: "make_payment",
            fb_user: @fb_user
          }
        }
      ]
    }

    @msg[:messages] << JsonFormatter.generate_simple_list(list_data)

    respond_to do |format|
      format.json { render :json => @msg }
    end
  end

  def make_payment
    order = Order.last_order(@fb_user)
    order.update_attribute("paid", true)

    @msg[:messages] << JsonFormatter.generate_message("Thank you for your payment! Please visit #{order.business_name} again.")

    respond_to do |format|
      format.json { render :json => @msg }
    end
  end

  private

  def set_fb_user
    @fb_user = params[:fb_user]
  end

  def set_msg_hash
    @msg = {
      messages: []
    }
  end

end
