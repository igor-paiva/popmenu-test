class Restaurant < ApplicationRecord
  has_many :menus, dependent: :nullify
  accepts_nested_attributes_for :menus

  belongs_to :current_menu, class_name: "Menu", optional: true

  validates :name, presence: true, uniqueness: true
end
