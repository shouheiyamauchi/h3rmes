class Order < ApplicationRecord
  belongs_to :user

  def self.check_outstanding(fb_user)
    Order.where(:fb_user=>fb_user, :paid=>false).count > 0
  end

  def self.last_order(fb_user)
    Order.where(:fb_user=>fb_user, :paid=>false).last
  end

  def append_item(result)
    if result == nil
    else
      array = self.order_list
      array << result
      self.update(order_list: array)
      self.save
    end
  end

  # used for views
  def find_total
    sum = 0
    self.order_list.each do |item|
      sum +=  item["price"]
    end
    return sum
  end

  def calculate_total
    order_total = 0
    self.order_list.each do |item|
      order_total += MenuItem.find(item).price
    end

    number_with_precision(order_total, precision: 2)
  end
end
