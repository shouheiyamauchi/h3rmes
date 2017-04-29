class MenuItem < ApplicationRecord
  belongs_to :menu_group
  mount_uploader :image, ImageUploader

  def self.search(search)
    item = MenuItem.where(:name=>search)
    if item[0] == nil
    else
      item.first
    end
  end
end
