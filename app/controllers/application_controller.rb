class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_menu_nav

  def set_menu_nav
    @menu_nav = MenuGroup.all
  end
end
