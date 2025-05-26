class MenuItem < ApplicationRecord
  belongs_to :menu

  validates_uniqueness_of :name
end
