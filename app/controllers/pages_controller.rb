class PagesController < ApplicationController
  require_relative "../../lib/json_formatter.rb"
  skip_before_filter :authenticate_user!
  before_filter :set_fb_user, :set_msg_hash

  def home
  end

  def list_business

    respond_to do |format|
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
      format.json  { render :json => @msg } # don't do msg.to_json
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
    @business_id = params[:business_id]
    respond_to do |format|
      msg = {
        "messages": [
          {
            "attachment": {
              "payload":{
                "template_type": "button",
                "text": "Please choose from the following options:",
                "buttons": [
                  {
                    "url": "#{ENV["APP_URL"]}/pages/list_categories.json?fb_user=#{@fb_user}&business_id=#{@business_id}",
                    "type":"json_plugin_url",
                    "title":"Order"
                  },
                  {
                    "url": "#{ENV["APP_URL"]}/pages/find_total.json?fb_user=#{@fb_user}&business_id=#{@business_id}",
                    "type":"json_plugin_url",
                    "title":"Checkout"
                  }
                ]
              },
              "type": "template"
            }
          }
        ]
      }
      format.json { render :json => msg }
    end
  end

  def list_categories
    @business_id = params[:business_id]

    respond_to do |format|
      @msg[:messages] << JsonFormatter.display_menu_categories(@fb_user, @business_id)
      format.json  { render :json => @msg } # don't do msg.to_json
    end
  end

  def list_foods
    @business_id = params[:business_id]
    @category_id = params[:category_id]
    respond_to do |format|
      msg = {
       "messages": [
          {
            "attachment":{
              "type":"template",
              "payload":{
                "template_type":"generic",
                "elements":[]
              }
            }
          }
        ]
      }

      MenuItem.where(:menu_group_id=>@category_id).each do |item|
        msg[:messages][0][:attachment][:payload][:elements] << {
          "title":"#{item.name}...$#{item.price}",
          "image_url":"#{item.image.url}",
          "subtitle":"#{item.description}",
          "buttons":[
            {
              "type":"json_plugin_url",
              "url":"#{ENV["APP_URL"]}/pages/add_item.json?item=#{URI.encode(item.name)}&fb_user=#{@fb_user}&business_id=#{@business_id}",
              "title":"Order Item"
            },
            {
              "type":"json_plugin_url",
              "url":"#{ENV["APP_URL"]}/pages/list_categories.json?fb_user=#{@fb_user}&business_id=#{@business_id}",
              "title":"Go Back"
            }
          ]
        }
      end

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def add_item
    @business_id = params[:business_id]
    @item = params[:item]
    @order = Order.where(:fb_user=>@fb_user, :paid=>false).first

    @order_list = @order.order_list
    @order_list << @item

    @order.update_attribute("order_list", @order_list)

    respond_to do |format|
      msg = {
        "messages": [
          {
            "attachment": {
              "type": "template",
              "payload": {
                "template_type": "button",
                "text": "You have ordered: #{@item} x 1",
                "buttons": []
              }
            }
          }
        ]
      }

      MenuGroup.where(:user_id => @business_id).order(id: :asc).each do |category|
        msg[:messages][0][:attachment][:payload][:buttons] << {
                "url": "#{ENV["APP_URL"]}/pages/list_foods.json?category_id=#{category.id}&fb_user=#{@fb_user}&business_id=#{@business_id}",
                "type":"json_plugin_url",
                "title":"#{category.name}"
              }
      end

      msg[:messages][0][:attachment][:payload][:buttons] << {
              "url": "#{ENV["APP_URL"]}/pages/main_menu.json?fb_user=#{@fb_user}&business_id=#{@business_id}",
              "type":"json_plugin_url",
              "title":"Go Back"
            }

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def find_total
    @business_id = params[:business_id]
    @order = Order.where(:fb_user=>@fb_user, :paid=>false).first
    @sum = 0
    @order_list = @order.order_list

    @order_list.each do |item|
      order_item = MenuItem.where(:name=>item).first
      @sum += order_item.price
    end



    respond_to do |format|
      msg = {
      "messages": [
        # {"text": "Your FB id is #{@fb_user}"},
        {"text": "You ordered the following:"}
        ]
      }

      @order.order_list.each do |item|
        msg[:messages] << {"text": "#{item}...$#{MenuItem.where(:name=>item).first.price}"}
      end
      msg[:messages] << {
        "attachment": {
          "payload":{
            "template_type": "button",
            "text": "The total for your order is $#{@sum}",
            "buttons": [
              {
                "url": "#{ENV["APP_URL"]}/pages/make_payment.json?fb_user=#{@fb_user}",
                "type":"json_plugin_url",
                "title":"Make Payment"
              }
            ]
          },
          "type": "template"
        }
      }

      format.json { render :json => msg }
    end
  end

  def make_payment
    @order = Order.where(:fb_user=>@fb_user, :paid=>false).first
    @order.update_attribute("paid", true)

    respond_to do |format|
      msg = {
      "messages": [
        # {"text": "Your FB id is #{@fb_user}"},
        {"text": "Thank you for your payment! Please visit #{@order.business_name} again."}
        ]
      }

      format.json { render :json => msg }
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
