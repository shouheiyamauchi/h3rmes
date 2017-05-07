class PagesController < ApplicationController
  def home
  end

  def json
    @variable = "hello there"
    respond_to do |format|
      msg = {
      "messages": [
          {
            "attachment": {
              "type": "template",
              "payload": {
                "template_type": "button",
                "text": "Total Price: #{@variable}<Insert Total>

                < Display total items >
                Would you like to pay now?",
                "buttons": [
                  {
                    "type": "show_block",
                    "block_name": "Pay",
                    "title": "Yes"
                  },
                  {
                    "type": "show_block",
                    "block_name": "Order - FB Cafe",
                    "title": "No"
                  }
                ]
              }
            }
          }
        ]
      }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def test
    @user_id = params[:user_id]
    @fb_id = params[:fb_id]
    respond_to do |format|
      msg = {
      "messages": [
        {"text": "Welcome to our store! User: #{@user_id}, FB ID: #{@fb_id}"},
        {"text": "How can I help you?"}
        ]
      }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def check_in
    @fb_user = params[:fb_user]
    @business = params[:business]
    @table_no = params[:table_no]
    respond_to do |format|
      msg = {
      "messages": [
        {"text": "Welcome to our #{@business}! You're at table no: #{@table_no}"},
        {
          "attachment": {
            "payload":{
              "template_type": "button",
              "text": "test JSON with postback",
              "buttons": [
                {
                  "url": "https://pacific-wave-33803.herokuapp.com/pages/test.json?fb_id={{messenger user id}}",
                  "type":"json_plugin_url",
                  "title":"go"
                }
              ]
            },
            "type": "template"
          }
        }
        ]
      }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def list_categories
    respond_to do |format|
      msg = {
        "messages": [
          {
            "attachment": {
              "type": "template",
              "payload": {
                "template_type": "button",
                "text": "Please choose your menu:",
                "buttons": []
              }
            }
          }
        ]
      }

      MenuGroup.all.each do |category|
        msg[:messages][0][:attachment][:payload][:buttons] << {
                "url": "https://pacific-wave-33803.herokuapp.com/pages/list_foods.json?category_id=#{category.id}",
                "type":"json_plugin_url",
                "title":"#{category.name}"
              }
      end

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def list_foods
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
              "url":"https://pacific-wave-33803.herokuapp.com/pages/add_item.json?item=#{item.name}",
              "title":"Order Item"
            },
            {
              "type":"json_plugin_url",
              "url":"https://pacific-wave-33803.herokuapp.com/pages/list_categories.json",
              "title":"Go Back to Categories"
            }
          ]
        }
      end

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def create_order
    @order = Order.new :user_id => params[:user_id], :table_number => params[:table_number], :fb_id => params[:fb_id], :business_name => params[:business_name]
    msg = {
    "messages": [
      {"text": "Your order was created."},
      {"text": "Thank you."}
      ]
    }
    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :json => success_msg }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity, response: request.body.read }
      end
    end
  end

  def add_item
    @item = params[:item]
    @fb_user = params[:fb_user]
    @order = Order.where(:fb_user=>@fb_user, :paid=>false).first

    @order_list = @order.order_list
    @order_list << @item

    @order.update_attribute("order_list", @order_list)

    respond_to do |format|
      msg = {
      "messages": [
        {"text": "You have ordered: #{@item}"},
        {"text": "Your current order includes: #{@order.order_list}"},
        {"text": "Your details are as follows: fb_id - #{@fb_user}, order id - #{@order.id}"}
        ]
      }

      format.json { render :json => msg }
    end
  end

  def find_total
    @fb_user = params[:fb_user]
    @order = Order.where(:fb_user=>@fb_user, :paid=>false).first
    @sum = 0
    @order_list = @order.order_list

    @order_list.each do |item|
      order_item = MenuItem.where(:name=>item).first
      @sum += order_item.price
    end

    @order.update_attribute("paid", true)

    respond_to do |format|
      msg = {
      "messages": [
        {"text": "Your FB id is #{@fb_user}"},
        {"text": "Your order id is #{@order.id}"},
        {"text": "Your order list is #{@order.order_list}"},
        {"text": "The total for your order is $#{@sum}"}
        ]
      }

      format.json { render :json => msg }
    end
  end
end
