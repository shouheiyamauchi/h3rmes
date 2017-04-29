class PagesController < ApplicationController
  def home
  end

  def stats
    @sum = 0
    Order.all.each do |order|
      sum += order.order_list.count
    end
  end
end
