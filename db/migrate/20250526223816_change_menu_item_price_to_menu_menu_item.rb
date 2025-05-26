class ChangeMenuItemPriceToMenuMenuItem < ActiveRecord::Migration[8.0]
  def up
    add_column :menu_menu_items, :price, :float

    menu_menu_items_data = []

    MenuMenuItem.includes(:menu_item).find_each do |menu_menu_item|
      menu_menu_items_data << menu_menu_item.attributes.merge(price: menu_menu_item.menu_item.price)
    end

    result = MenuMenuItem.upsert_all(menu_menu_items_data, returning: %i[id])

    if result.length != menu_menu_items_data.size
      raise "An error occurred while updating menu menu items, not all menu menu items were updated"
    end
  end

  def down
    menu_items_data = []

    MenuMenuItem.select(:id, :price, :menu_item_id).find_each do |menu_menu_item|
      menu_items_data << {
        id: menu_menu_item.menu_item_id,
        price: menu_menu_item.price,
        name: menu_menu_item.menu_item.name
      }
    end

    result = MenuItem.upsert_all(menu_items_data, returning: %i[id])

    if result.length != menu_items_data.size
      raise "An error occurred while updating menu items, not all menu items were updated"
    end

    remove_column :menu_menu_items, :price
  end
end
