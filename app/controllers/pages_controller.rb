class PagesController < ApplicationController
  skip_before_filter :authenticate_user!
  # h3rmes.herokuapp.com

  def home
  end

  def list_business
    puts Api.message

    @fb_user = params[:fb_user]

    respond_to do |format|
      # Finalize any outstanding orders
      if Order.check_outstanding(@fb_user)
        msg = {
          "messages": [
            {
              "attachment": {
                "payload":{
                  "template_type": "button",
                  "text": "Please pay an outstanding order - User: #{@fb_user}:",
                  "buttons": [
                    {
                      "url":"#{ENV["APP_URL"]}/pages/find_total.json?fb_user=#{@fb_user}",
                      "type":"json_plugin_url",
                      "title":"Finalize Order"
                    }
                  ]
                },
                "type": "template"
              }
            }
          ]
        }
      else
        msg = Api.display_business_list
      end
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end

  def create_order
    @fb_user = params[:fb_user]
    @business_id = params[:business_id]
    @order = Order.new :user_id => @business_id, :fb_user => params[:fb_user], :business_name => User.find(@business_id).name
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
                  "url":"#{ENV["APP_URL"]}/pages/main_menu.json?fb_user=#{@fb_user}&business_id=#{@business_id}",
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
    @fb_user = params[:fb_user]
    @business_id = params[:business_id]
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

  def list_foods
    @fb_user = params[:fb_user]
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
    @fb_user = params[:fb_user]
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
    @fb_user = params[:fb_user]
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
