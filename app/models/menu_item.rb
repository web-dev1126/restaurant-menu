class MenuItem < ApplicationRecord
  # Associations
  has_many :menu_item_menus, dependent: :destroy
  has_many :menus, through: :menu_item_menus
  has_many :restaurants, through: :menus

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: true
  validates :description, length: { maximum: 500 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true, length: { minimum: 2, maximum: 50 }
  validates :available, inclusion: { in: [true, false] }

  # Scopes
  scope :available, -> { where(available: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :ordered_by_name, -> { order(:name) }
  scope :ordered_by_price, -> { order(:price) }

  # Instance methods
  def formatted_price
    "$%.2f" % price
  end

  def available?
    menus.active.exists?
  end
end 