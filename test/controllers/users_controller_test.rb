require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
	  @base_title = "Sample Application"
  end

  test "should get new" do
    get signup_path
    assert_response :success
	  assert_select "title", "Sign Up | #{@base_title}"
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

end
