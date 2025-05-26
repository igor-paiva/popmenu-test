class Menu < ApplicationRecord
  belongs_to :restaurant, optional: true

  has_many :menu_items, dependent: :destroy
  accepts_nested_attributes_for :menu_items
end
