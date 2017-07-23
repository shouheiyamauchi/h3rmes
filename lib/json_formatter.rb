class JsonFormatter

  def self.message
    "Check if this works"
  end

  def self.display_business_list
    business_list = {
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

    User.all.each do |business|
      business_list[:messages][0][:attachment][:payload][:elements] << {
        "title":"#{business.name}",
        "image_url":"",
        "subtitle":"",
        "buttons":[
          {
            "type": "json_plugin_url",
            "url": "#{ENV["APP_URL"]}/pages/create_order.json?business_id=#{business.id}&fb_user=#{@fb_user}&business_id=#{business.id}&table_number=#{@table_number}",
            "title": "Check in"
          }
        ]
      }
    end

    business_list
  end

end
