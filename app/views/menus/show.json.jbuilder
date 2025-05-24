json.partial! "menus/menu", menu: @menu

json.menu_items @menu.menu_items do |menu_item|
  json.partial! "menu_items/menu_item", menu_item: menu_item
end
