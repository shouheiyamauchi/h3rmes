class MenuGroup < ApplicationRecord
  belongs_to :user
  has_many :menu_items
end
