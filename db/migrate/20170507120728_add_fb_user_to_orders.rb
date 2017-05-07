class AddFbUserToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :fb_id, :integer, :limit => 5
  end
end
