class MenuItem < ApplicationRecord
  belongs_to :menu_group
  mount_uploader :image, ImageUploader

  def self.search(search)
    if search == nil
    else
    where("name LIKE ?", "%#{search}%")
    end
  end
end
