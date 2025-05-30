class AddNullFalseToMenuName < ActiveRecord::Migration[8.0]
  def change
    change_column_null :menus, :name, false
  end
end
