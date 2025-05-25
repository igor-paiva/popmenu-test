class MenuItem < ApplicationRecord
  belongs_to :menu

  validates_uniqueness_of :name, scope: :menu_id
end
