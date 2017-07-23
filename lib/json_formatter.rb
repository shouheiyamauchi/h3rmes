class JsonFormatter

  def self.display_business_list
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
        "button_title": "Check in"
      }
    end

    generate_sliding_list_json(business_list)
  end

  private

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
            "url": "#{ENV["APP_URL"]}/pages/create_order.json",
            "title": item[:button_title]
          }
        ]
      }
    end

    sliding_list
  end

end
