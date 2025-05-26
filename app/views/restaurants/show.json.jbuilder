json.partial! "restaurants/restaurant", restaurant: @restaurant

json.menus @restaurant.menus do |menu|
  json.partial! "menus/menu", menu:
end
