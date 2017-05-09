class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :set_menu_nav

  def set_menu_nav
    if user_signed_in?
      @menu_nav = MenuGroup.where(:user_id => current_user.id)
    end
  end
end
