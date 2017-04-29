class AddDefaultToOrders < ActiveRecord::Migration[5.0]
  def change
    change_column :orders, :order_list, :json, :default => []
  end
end
