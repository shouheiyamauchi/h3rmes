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

  def find_total
    sum = 0
    self.order_list.each do |item|
      sum +=  item["price"]
    end
    return sum
  end

  def calculate_total
    sum = 0
    self.order_list.each do |item|
      sum += MenuItem.find(item).price
    end

    sum
  end
end
