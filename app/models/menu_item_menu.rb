class MenuItemMenu < ApplicationRecord
  belongs_to :menu_item
  belongs_to :menu

  validates :menu_item_id, uniqueness: { scope: :menu_id }
end 