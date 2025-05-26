class AddForeignKeyToMenuIdOnMenuItem < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :menu_items, :menus, column: :menu_id, on_delete: :nullify
  end
end
