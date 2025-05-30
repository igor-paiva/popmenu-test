class AddNullFalseToMenuItemsName < ActiveRecord::Migration[8.0]
  def change
    change_column_null :menu_items, :name, false
  end
end
