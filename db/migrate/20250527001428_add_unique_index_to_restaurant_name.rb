class AddUniqueIndexToRestaurantName < ActiveRecord::Migration[8.0]
  def change
    add_index :restaurants, :name, unique: true
  end
end
