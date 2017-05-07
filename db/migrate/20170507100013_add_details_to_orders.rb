class AddDetailsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :fb_id, :integer
    add_column :orders, :business_name, :string
  end
end
