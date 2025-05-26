class ChangeMenuItemNameUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :menu_items, %i[name menu_id]

    add_index :menu_items, :name, unique: true
  end
end
