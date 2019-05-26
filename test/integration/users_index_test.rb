require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
    @user.save

    @admin = User.new(name: "Admin User", email: "admin@example.com",
                      password: "foobar", password_confirmation: "foobar", admin: "true",
                      activated: true, activated_at: Time.zone.now)
    @admin.save

    30.times do |n|
      User.create(name: "User #{n}", email: "user-#{n}@example.com",
                  password: "foobar", password_confirmation: "foobar",
                  activated: true, activated_at: Time.zone.now)
    end
  end

  test "index including pagination" do
    log_in_as(User.first, password:  "foobar")
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.page(1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin, password: "foobar")
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.page(1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    assert_difference 'User.count', -1 do
      delete user_path(@user)
    end
  end

  test "index as non-admin" do
    log_in_as(@user, password: "foobar")
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

	def teardown
    User.distinct(:id).each do |id|
			User.find(id).destroy
		end
  end
end
