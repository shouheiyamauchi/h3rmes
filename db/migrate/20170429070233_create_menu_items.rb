class CreateMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :menu_items do |t|
      t.references :menu_group, foreign_key: true
      t.float :price
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
