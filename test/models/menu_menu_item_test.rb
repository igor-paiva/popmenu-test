require "test_helper"

class MenuMenuItemTest < ActiveSupport::TestCase
  test "should associate menu with menu item through menu menu item" do
    menu = Menu.create!(
      name: "Test Menu",
      description: "Test Description",
      restaurant: restaurants(:one)
    )

    menu_item_one = MenuItem.create!(
      name: "Test Pizza",
      description: "Delicious test pizza",
      price: 12.99,
      picture_url: "https://www.coisasdaroca.com/wp-content/uploads/2023/01/Origem-da-pizza.png"
    )

    MenuMenuItem.create!(menu:, menu_item: menu_item_one, price: 11.99)

    assert_equal [ menu_item_one ], menu.menu_items
    assert_equal [ menu ], menu_item_one.menus

    menu_item_two = MenuItem.create!(
      name: "Test Burguer", description: "Delicious test burguer", price: 15.99
    )

    MenuMenuItem.create!(menu:, menu_item: menu_item_two, price: 15.99)

    assert_equal [ menu_item_one, menu_item_two ], menu.reload.menu_items
    assert_equal [ menu ], menu_item_one.menus
    assert_equal [ menu ], menu_item_two.menus
  end

  test "should validate presence of price" do
    menu_menu_item = MenuMenuItem.new(menu: menus(:one), menu_item: menu_items(:one))

    assert_not menu_menu_item.valid?
    assert_equal [ "Price is not a number" ], menu_menu_item.errors.full_messages

    menu_menu_item = MenuMenuItem.new(menu: menus(:one), menu_item: menu_items(:one), price: 0)

    assert_not menu_menu_item.valid?
    assert_equal [ "Price must be greater than 0" ], menu_menu_item.errors.full_messages
  end
end
