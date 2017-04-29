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
end
