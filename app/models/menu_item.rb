class MenuItem < ApplicationRecord
  has_many :menu_menu_items, dependent: :destroy
  accepts_nested_attributes_for :menu_menu_items

  has_many :menus, through: :menu_menu_items

  validates_uniqueness_of :name
end
