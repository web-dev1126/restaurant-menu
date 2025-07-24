class Menu < ApplicationRecord
  # Associations
  belongs_to :restaurant
  has_many :menu_item_menus, dependent: :destroy
  has_many :menu_items, through: :menu_item_menus

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: { scope: :restaurant_id }
  validates :description, length: { maximum: 500 }
  validates :active, inclusion: { in: [true, false] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered_by_name, -> { order(:name) }

  # Instance methods
  def available_items_count
    menu_items.where(available: true).count
  end

  def total_items_count
    menu_items.count
  end
end 