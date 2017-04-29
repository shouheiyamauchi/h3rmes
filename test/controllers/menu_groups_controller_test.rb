require 'test_helper'

class MenuGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu_group = menu_groups(:one)
  end

  test "should get index" do
    get menu_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_menu_group_url
    assert_response :success
  end

  test "should create menu_group" do
    assert_difference('MenuGroup.count') do
      post menu_groups_url, params: { menu_group: { description: @menu_group.description, name: @menu_group.name, user_id: @menu_group.user_id } }
    end

    assert_redirected_to menu_group_url(MenuGroup.last)
  end

  test "should show menu_group" do
    get menu_group_url(@menu_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_menu_group_url(@menu_group)
    assert_response :success
  end

  test "should update menu_group" do
    patch menu_group_url(@menu_group), params: { menu_group: { description: @menu_group.description, name: @menu_group.name, user_id: @menu_group.user_id } }
    assert_redirected_to menu_group_url(@menu_group)
  end

  test "should destroy menu_group" do
    assert_difference('MenuGroup.count', -1) do
      delete menu_group_url(@menu_group)
    end

    assert_redirected_to menu_groups_url
  end
end
