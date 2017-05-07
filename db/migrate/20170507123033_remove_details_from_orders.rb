class RemoveDetailsFromOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :fb_user, :integer
  end
end
