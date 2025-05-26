class MenuMenuItem < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :price, numericality: { greater_than: 0 }
end
