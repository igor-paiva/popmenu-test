class AddUniqueIndexToMenuItemName < ActiveRecord::Migration[8.0]
  def change
    add_index :menu_items, %i[name menu_id], unique: true
  end
end
