class JsonFormatter

  def self.display_business_list(fb_user)
    business_list = []

    User.all.each do |business|
      business_list << {
        "title": business.name,
        "button_title": "Check in",
        "url_data": {
          "next_action": "create_order",
          "fb_user": fb_user,
          "other_params": "&business_id=#{business.id}"
        }
      }
    end

    generate_sliding_list_json(business_list)
  end

  def self.display_menu_categories(fb_user, business_id)
    menu_categories = []

    MenuGroup.where(:user_id => business_id).order(id: :asc).each do |category|
      menu_categories << {
              "title":"#{category.name}",
              "button_title": "Select category",
              "url_data": {
                "next_action": "list_foods",
                "fb_user": fb_user,
                "other_params": "&business_id=#{business_id}&category_id=#{category.id}"
              }
            }
    end

    generate_sliding_list_json(menu_categories)
  end

  def self.create_url(params)
    "#{ENV["APP_URL"]}/pages/#{params[:next_action]}.json?fb_user=#{params[:fb_user]}#{params[:other_params]}"
  end

  def self.generate_sliding_list_json(data)
    sliding_list = {
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

    data.each do |item|
      sliding_list[:messages][0][:attachment][:payload][:elements] << {
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

  # list is limited to 3 items, otherwise it won't display
  def self.generate_simple_list(data)
puts data.inspect

    simple_list = {
      "messages": [
        {
          "attachment": {
            "payload":{
              "template_type": "button",
              "text": "Please pay an outstanding order - User: #{@fb_user}:",
              "buttons": []
            },
            "type": "template"
          }
        }
      ]
    }

    data.each do |item|
      simple_list[:messages][0][:attachment][:payload][:buttons] << {
        "type": "json_plugin_url",
        "url": create_url(item[:url_data]),
        "title": item[:button_title]
      }
    end

    simple_list
  end

end
