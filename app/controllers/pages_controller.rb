class PagesController < ApplicationController
  def home
  end

  def json
  respond_to do |format|
    msg = {"messages": [{"text": "Welcome to our store!"},{"text": "How can I help you?"}]}
    format.json  { render :json => msg } # don't do msg.to_json
  end
end
end
