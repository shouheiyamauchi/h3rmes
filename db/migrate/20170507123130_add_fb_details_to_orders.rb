class AddFbDetailsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :fb_user, :string
  end
end
