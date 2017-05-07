class RemoveFbIdFromOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :fb_id, :integer
  end
end
