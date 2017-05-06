class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :set_menu_nav

  def set_menu_nav
    @menu_nav = MenuGroup.all
  end
end
