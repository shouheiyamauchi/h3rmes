class AddFbToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :fb_user, :integer, :limit => 5
  end
end
