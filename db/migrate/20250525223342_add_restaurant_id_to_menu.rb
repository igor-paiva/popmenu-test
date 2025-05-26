class AddRestaurantIdToMenu < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :restaurant_id, :bigint, null: true
    add_foreign_key :menus, :restaurants, column: :restaurant_id, on_delete: :nullify
  end
end
