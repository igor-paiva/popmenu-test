class Restaurant < ApplicationRecord
  has_many :menus, dependent: :nullify
  accepts_nested_attributes_for :menus
end
