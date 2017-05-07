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

  def choose_business
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
                "text": "Hello!",
                "buttons": [
                  {
                    "type": "web_url",
                    "url": "https://petersapparel.parseapp.com/buy_item?item_id=100",
                    "title": "Buy Item"
                  }
                ]
              }
            }
          }
        ]
      }

      MenuGroup.all.each do |category|
        msg[:messages][0][:attachment][:payload][:buttons] << {
                "url": "https://pacific-wave-33803.herokuapp.com/pages/params_test.json?category=#{category.name}",
                "type":"json_plugin_url",
                "title":"#{category.name}"
              }
      end

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def params_test
    @category = params[:category]

    respond_to do |format|
      msg = {
        "messages": [
          {
            "attachment": {
              "type": "template",
              "payload": {
                "template_type": "button",
                "text": "The category you chose is:",
                "buttons": [
                  {
                    "type": "web_url",
                    "url": "https://petersapparel.parseapp.com/buy_item?item_id=100",
                    "title": "#{@category}"
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

  def list_foods
    respond_to do |format|
      msg = {
       "messages": [
          {
            "attachment":{
              "type":"template",
              "payload":{
                "template_type":"generic",
                "elements":[
                  {
                    "title":"Classic White T-Shirt",
                    "image_url":"https://h3rmes.s3.amazonaws.com/uploads/menu_item/image/2/4.jpg",
                    "subtitle":"Soft white cotton t-shirt is back in style",
                    "buttons":[
                      {
                        "type":"web_url",
                        "url":"https://petersapparel.parseapp.com/view_item?item_id=100",
                        "title":"View Item"
                      },
                      {
                        "type":"web_url",
                        "url":"https://petersapparel.parseapp.com/buy_item?item_id=100",
                        "title":"Buy Item"
                      }
                    ]
                  },
                  {
                    "title":"Classic Grey T-Shirt",
                    "image_url":"https://h3rmes.s3.amazonaws.com/uploads/menu_item/image/4/5.jpg",
                    "subtitle":"Soft gray cotton t-shirt is back in style",
                    "buttons":[
                      {
                        "type":"web_url",
                        "url":"https://petersapparel.parseapp.com/view_item?item_id=101",
                        "title":"View Item"
                      },
                      {
                        "type":"web_url",
                        "url":"https://petersapparel.parseapp.com/buy_item?item_id=101",
                        "title":"Buy Item"
                      }
                    ]
                  }
                ]
              }
            }
          }
        ]
      }

      msg[:messages][0][:attachment][:payload][:elements] << {
        "title":"Classic White T-Shirt",
        "image_url":"https://h3rmes.s3.amazonaws.com/uploads/menu_item/image/2/4.jpg",
        "subtitle":"Soft white cotton t-shirt is back in style",
        "buttons":[
          {
            "type":"web_url",
            "url":"https://petersapparel.parseapp.com/view_item?item_id=100",
            "title":"View Item"
          },
          {
            "type":"web_url",
            "url":"https://petersapparel.parseapp.com/buy_item?item_id=100",
            "title":"Buy Item"
          }
        ]
      }

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def create_order
    @order = Order.new :table_number => params[:table_number], :fb_id => params[:fb_id], :business_name => params[:business_name]
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
    @item = "Curry"
    @fb_user = params[:fb_user]
    @order = Order.where(:fb_user=>@fb_user).first

    @order_list = @order.order_list
    @order_list << @item

    @order.update_attribute("order_list", @order_list)

    respond_to do |format|
      msg = {
      "messages": [
        {"text": "You order id is #{@order.id}}"},
        {"text": "Your current orde includers: #{@order.order_list}"}
        ]
      }

      format.json { render :json => msg }
    end
  end

  def find_total
    @order = Order.where(:fb_user=>@fb_user).first
    @sum = 0
    @order_list = @order.order_list

    @order_list.each do |item|
      order_item = MenuItem.where(:name=>item).first
      @sum += order_item.price
    end

    respond_to do |format|
      msg = {
      "messages": [
        {"text": "Your order list is #{@order_list}"},
        {"text": "The total for your order is $#{@sum}"}
        ]
      }

      format.json { render :json => msg }
    end
  end
end
