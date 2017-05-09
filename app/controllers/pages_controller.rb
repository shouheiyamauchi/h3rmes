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

  def create_order
    @order = Order.new :user_id => params[:user_id], :table_number => params[:table_number], :fb_user => params[:fb_user], :business_name => params[:business_name]
    @fb_user = params[:fb_user]
    msg =
    {
      "messages": [
        {
          "attachment": {
            "payload":{
              "template_type": "button",
              "text": "Welcome to #{@order.business_name}!",
              "buttons": [
                {
                  "url": "https://pacific-wave-33803.herokuapp.com/pages/main_menu.json?fb_user=#{@fb_user}",
                  "type":"json_plugin_url",
                  "title":"Continue"
                }
              ]
            },
            "type": "template"
          }
        }
      ]
    }
    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :json => msg }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity, response: request.body.read }
      end
    end
  end

  def main_menu
    @fb_user = params[:fb_user]
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
                    "url": "https://pacific-wave-33803.herokuapp.com/pages/list_categories.json?fb_user=#{@fb_user}",
                    "type":"json_plugin_url",
                    "title":"Order"
                  },
                  {
                    "url": "https://pacific-wave-33803.herokuapp.com/pages/find_total.json?fb_user=#{@fb_user}",
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
    @fb_user = params[:fb_user]
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
                "url": "https://pacific-wave-33803.herokuapp.com/pages/list_foods.json?category_id=#{category.id}&fb_user=#{@fb_user}",
                "type":"json_plugin_url",
                "title":"#{category.name}"
              }
      end

      msg[:messages][0][:attachment][:payload][:buttons] << {
              "url": "https://pacific-wave-33803.herokuapp.com/pages/main_menu.json?fb_user=#{@fb_user}",
              "type":"json_plugin_url",
              "title":"Go Back"
            }

      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def list_foods
    @fb_user = params[:fb_user]
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
              "url":"https://pacific-wave-33803.herokuapp.com/pages/add_item.json?item=#{URI.encode(item.name)}&fb_user=#{@fb_user}",
              "title":"Order Item"
            },
            {
              "type":"json_plugin_url",
              "url":"https://pacific-wave-33803.herokuapp.com/pages/list_categories.json?fb_user=#{@fb_user}",
              "title":"Go Back"
            }
          ]
        }
      end

      format.json  { render :json => msg } # don't do msg.to_json
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

      MenuGroup.all.each do |category|
        msg[:messages][0][:attachment][:payload][:buttons] << {
                "url": "https://pacific-wave-33803.herokuapp.com/pages/list_foods.json?category_id=#{category.id}&fb_user=#{@fb_user}",
                "type":"json_plugin_url",
                "title":"#{category.name}"
              }
      end

      msg[:messages][0][:attachment][:payload][:buttons] << {
              "url": "https://pacific-wave-33803.herokuapp.com/pages/main_menu.json?fb_user=#{@fb_user}",
              "type":"json_plugin_url",
              "title":"Go Back"
            }

      format.json  { render :json => msg } # don't do msg.to_json
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



    respond_to do |format|
      msg = {
      "messages": [
        # {"text": "Your FB id is #{@fb_user}"},
        {"text": "Your table number is #{@order.table_number}"},
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
                "url": "https://pacific-wave-33803.herokuapp.com/pages/make_payment.json?fb_user=#{@fb_user}",
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
    @fb_user = params[:fb_user]
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
end
