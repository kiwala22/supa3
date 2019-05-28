require 'test_helper'

class BroadcastsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get broadcasts_index_url
    assert_response :success
  end

  test "should get new" do
    get broadcasts_new_url
    assert_response :success
  end

  test "should get edit" do
    get broadcasts_edit_url
    assert_response :success
  end

  test "should get uodate" do
    get broadcasts_uodate_url
    assert_response :success
  end

  test "should get delete" do
    get broadcasts_delete_url
    assert_response :success
  end

end
