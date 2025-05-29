require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "should create menu with multiple menu items" do
    menu_item = MenuItem.create!(
      name: "Test Bread",
      description: "Delicious test bread",
      price: 3.99
    )

    menu = Menu.create!(
      name: "Test Menu",
      description: "Test Description",
      restaurant: restaurants(:one),
      menu_menu_items_attributes: [ { menu_item:, price: 3.99 } ]
    )

    assert_equal 1, menu.menu_items.count

    MenuItem.create!(
      name: "Test Pizza",
      description: "Delicious test pizza",
      price: 12.99,
      picture_url: "https://www.coisasdaroca.com/wp-content/uploads/2023/01/Origem-da-pizza.png",
      menu_menu_items_attributes: [ { menu_id: menu.id, price: 13.99 } ]
    )

    assert_equal 2, menu.reload.menu_items.count
    assert_equal 2, menu.menu_menu_items.count
  end

  test "should NOT destroy menu items when menu is destroyed" do
    menu = menus(:one)

    assert_no_difference "MenuItem.count" do
      menu.destroy!
    end

    assert_nil Menu.find_by(id: menu.id)
  end

  test "should require name to be present" do
    menu = Menu.new(restaurant: restaurants(:one))

    assert_not menu.valid?
    assert_includes menu.errors[:name], "can't be blank"
  end

  test "should require name to be unique within same restaurant" do
    existing_menu = menus(:one)
    duplicate_menu = Menu.new(
      name: existing_menu.name,
      restaurant: existing_menu.restaurant
    )

    assert_not duplicate_menu.valid?
    assert_includes duplicate_menu.errors[:name], "has already been taken"
  end

  test "should allow same menu name in different restaurants" do
    restaurant_one = restaurants(:one)
    restaurant_two = restaurants(:two)

    Menu.create!(name: "Same Menu Name", restaurant: restaurant_one)
    menu_two = Menu.new(name: "Same Menu Name", restaurant: restaurant_two)

    assert menu_two.valid?
    assert menu_two.save
  end

  test "should allow different menu names in same restaurant" do
    restaurant = restaurants(:one)

    Menu.create!(name: "Menu One", restaurant: restaurant)
    menu_two = Menu.new(name: "Menu Two", restaurant: restaurant)

    assert menu_two.valid?
  end
end
