class AddUniqueIndexToMenuName < ActiveRecord::Migration[8.0]
  def change
    add_index :menus, %i[name restaurant_id], unique: true
  end
end
