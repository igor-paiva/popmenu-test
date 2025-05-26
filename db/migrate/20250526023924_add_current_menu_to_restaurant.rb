class AddCurrentMenuToRestaurant < ActiveRecord::Migration[8.0]
  def change
    add_reference :restaurants, :current_menu, foreign_key: { to_table: :menus }
  end
end
