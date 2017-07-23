class JsonFormatter

  def self.display_business_list(fb_user)
    # business_list = {
    #  "messages": [
    #     {
    #       "attachment":{
    #         "type":"template",
    #         "payload":{
    #           "template_type":"generic",
    #           "elements":[]
    #         }
    #       }
    #     }
    #   ]
    # }
    #
    # User.all.each do |business|
    #   business_list[:messages][0][:attachment][:payload][:elements] << {
    #     "title":"#{business.name}",
    #     "image_url":"",
    #     "subtitle":"",
    #     "buttons":[
    #       {
    #         "type": "json_plugin_url",
    #         "url": "#{ENV["APP_URL"]}/pages/create_order.json?business_id=#{business.id}&fb_user=#{@fb_user}&business_id=#{business.id}&table_number=#{@table_number}",
    #         "title": "Check in"
    #       }
    #     ]
    #   }
    # end
    #
    # business_list

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

  private

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

end
