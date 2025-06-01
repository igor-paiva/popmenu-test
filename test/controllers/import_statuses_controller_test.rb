require "test_helper"

class ImportStatusesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get import_statuses_show_url
    assert_response :success
  end
end
