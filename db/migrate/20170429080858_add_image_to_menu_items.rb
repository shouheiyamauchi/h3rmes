class AddImageToMenuItems < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_items, :image, :string
  end
end
