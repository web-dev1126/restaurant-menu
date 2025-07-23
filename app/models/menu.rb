class Menu < ApplicationRecord
  # Associations
  has_many :menu_items, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: true
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