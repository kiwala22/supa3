require 'test_helper'

class GamersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gamers_index_url
    assert_response :success
  end

end
