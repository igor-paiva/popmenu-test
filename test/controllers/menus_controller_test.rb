require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  test "should return all menus on index" do
    get menus_url, as: :json

    assert_response :success

    assert_equal 2, response.parsed_body.count
  end

  test "should return menu with menu items on show" do
    menu = menus(:one)

    get menu_url(menu), as: :json

    assert_response :success

    parsed_response = response.parsed_body

    assert_equal menu.id, parsed_response["id"]
    assert_equal menu.name, parsed_response["name"]
    assert_equal menu.description, parsed_response["description"]

    assert_equal 2, parsed_response["menu_items"].count
  end
end
