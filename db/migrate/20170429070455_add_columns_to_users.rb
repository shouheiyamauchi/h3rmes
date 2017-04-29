class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :string
    add_column :users, :description, :text
    add_column :users, :category, :string
    add_column :users, :location, :string
  end
end
