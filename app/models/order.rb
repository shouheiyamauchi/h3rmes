class Order < ApplicationRecord
  belongs_to :user
  skip_before_action :verify_authenticity_token, if: :json_request?

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

  protected

  def json_request? request.format.json?
  end
end
