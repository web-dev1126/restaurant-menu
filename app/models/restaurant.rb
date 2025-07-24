class Restaurant < ApplicationRecord
  # Associations
  has_many :menus, dependent: :destroy
  has_many :menu_items, through: :menus

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: true
  validates :description, length: { maximum: 500 }
  validates :address, length: { maximum: 200 }
  validates :phone, length: { maximum: 20 }
  validates :active, inclusion: { in: [true, false] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered_by_name, -> { order(:name) }

  # Instance methods
  def active_menus_count
    menus.where(active: true).count
  end

  def total_menus_count
    menus.count
  end

  def total_menu_items_count
    menu_items.count
  end

  def available_menu_items_count
    menu_items.where(available: true).count
  end
end 