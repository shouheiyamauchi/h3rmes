class MenuItem < ApplicationRecord
  belongs_to :menu_group
  mount_uploader :image, ImageUploader
end
