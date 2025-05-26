require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "should create menu with multiple menu items" do
    menu = Menu.create!(
      name: "Test Menu",
      description: "Test Description",
      restaurant: restaurants(:one),
      menu_items_attributes: [
        {
          name: "Test Bread",
          description: "Delicious test bread",
          price: 3.99
        }
      ]
    )

    assert_equal 1, menu.menu_items.count

    menu.menu_items.build(
      name: "Test Pizza",
      description: "Delicious test pizza",
      price: 12.99,
      picture_url: "https://www.coisasdaroca.com/wp-content/uploads/2023/01/Origem-da-pizza.png"
    )

    menu.save!

    assert_equal 2, menu.menu_items.count
  end

  test "should NOT destroy menu items when menu is destroyed" do
    menu = menus(:one)

    assert_no_difference "MenuItem.count" do
      menu.destroy!
    end

    assert_nil Menu.find_by(id: menu.id)
  end
end
