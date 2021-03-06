class JsonFormatter

  def self.display_business_list(fb_user)
    business_list = []

    User.all.each do |business|
      business_list << {
        "title": business.name,
        "button_title": "Check In",
        "url_data": {
          "next_action": "create_order",
          "fb_user": fb_user,
          "other_params": "&business_id=#{business.id}"
        }
      }
    end

    generate_sliding_list(business_list)
  end

  def self.generate_categories_list(fb_user, business_id)
    menu_categories = []

    MenuGroup.where(:user_id => business_id).order(id: :asc).each do |category|
      menu_categories << {
              "title":"#{category.name}",
              "subtitle":"#{category.description}",
              "button_title": "Select Category",
              "url_data": {
                "next_action": "list_items",
                "fb_user": fb_user,
                "other_params": "&business_id=#{business_id}&category_id=#{category.id}"
              }
            }
    end

    sliding_list = generate_sliding_list(menu_categories)

    add_go_back_button(sliding_list, "main_menu", fb_user, business_id)
  end

  def self.generate_items_list(fb_user, business_id, category_id)
    menu_items = []

    MenuItem.where(:menu_group_id => category_id).each do |item|
      menu_items << {
        "title":"#{item.name}...$#{item.price}",
        "image_url":"#{item.image.url}",
        "subtitle":"#{item.description}",
        "button_title": "Order Item",
        "url_data": {
          "next_action": "add_item",
          "fb_user": fb_user,
          "other_params": "&business_id=#{business_id}&item=#{item.id}"
        }
      }
    end

    sliding_list = generate_sliding_list(menu_items)

    add_go_back_button(sliding_list, "list_categories", fb_user, business_id)
  end

  def self.generate_message(message)
    { "text": message }
  end

  # list is limited to 3 items, otherwise it won't display
  def self.generate_simple_list(list_data)
    simple_list = {
      "attachment": {
        "payload":{
          "template_type": "button",
          "text": list_data[:text],
          "buttons": []
        },
        "type": "template"
      }
    }

    list_data[:buttons].each do |item|
      simple_list[:attachment][:payload][:buttons] << {
        "type": "json_plugin_url",
        "url": create_url(item[:url_data]),
        "title": item[:button_title]
      }
    end

    simple_list
  end

  def self.generate_sliding_list(list_data)
    sliding_list = {
      "attachment": {
        "type": "template",
        "payload": {
          "template_type": "generic",
          "elements": []
        }
      }
    }

    list_data.each do |item|
      sliding_list[:attachment][:payload][:elements] << {
        "title": item[:title],
        "image_url": item[:image_url],
        "subtitle": item[:subtitle],
        "buttons":[
          {
            "type": "json_plugin_url",
            "url": create_url(item[:url_data]),
            "title": item[:button_title]
          }
        ]
      }
    end

    sliding_list
  end

  def self.add_go_back_button(sliding_list, action_name, fb_user, business_id)
    url_data = {
      "next_action": action_name,
      "fb_user": fb_user,
      "other_params": "&business_id=#{business_id}"
    }

    sliding_list[:attachment][:payload][:elements].each do |item|
      item[:buttons] << {
        type: "json_plugin_url",
        url: create_url(url_data),
        title: "Go Back"
      }
    end

    sliding_list
  end

  private

  def self.create_url(params)
    "#{ENV["APP_URL"]}/pages/#{params[:next_action]}.json?fb_user=#{params[:fb_user]}#{params[:other_params]}"
  end

end
