require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
		30.times do |n|
			User.create(name: "User #{n}", email: "user-#{n}@example.com",
									password: "foobar", password_confirmation: "foobar")
    end
  end

  test "index including pagination" do
    log_in_as(User.first,	password: "foobar")
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.page(1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

	def teardown
    User.distinct(:id).each do |id|
			User.find(id).destroy
		end
  end
end
