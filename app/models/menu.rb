class Menu < ApplicationRecord
  belongs_to :restaurant, optional: true

  has_many :menu_menu_items, dependent: :destroy
  accepts_nested_attributes_for :menu_menu_items

  has_many :menu_items, through: :menu_menu_items

  validates :name, presence: true, uniqueness: { scope: :restaurant_id }
end
