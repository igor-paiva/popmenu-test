class Restaurant < ApplicationRecord
  has_many :menus
  accepts_nested_attributes_for :menus
end
