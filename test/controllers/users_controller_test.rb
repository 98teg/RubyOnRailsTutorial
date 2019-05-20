require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = "Sample Application"
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
					 activated: true, activated_at: Time.zone.now)
    @user.save

    @admin = User.new(name: "Admin User", email: "admin@example.com",
                     password: "foobar", password_confirmation: "foobar", admin: "true",
					 activated: true, activated_at: Time.zone.now)
    @admin.save
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

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@user, password: "foobar")
    assert_not @user.admin
    patch user_path(@user), params: {
                              user: { password: "foobar",
                                      password_confirmation: "foobar",
                                      admin: true } }
    assert_not @user.reload.admin
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user, password: "foobar")
    end

    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@user, password: "foobar")
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end

    assert_redirected_to root_url
  end

  def teardown
    @user.destroy
    @admin.destroy
  end
end
