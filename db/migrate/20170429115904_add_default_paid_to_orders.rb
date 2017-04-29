class AddDefaultPaidToOrders < ActiveRecord::Migration[5.0]
  def change
    change_column :orders, :paid, :boolean, :default => false
  end
end
