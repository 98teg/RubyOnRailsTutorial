require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

	30.times do
   	  @user.microposts.create(content: "Lorem ipsum", created_at: 30.minutes.ago)
    end

    @user1 = User.create(name: "Example User", email: "user1@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
  end

  test "micropost interface" do
    log_in_as(@user, password: "foobar")
    get root_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference '@user.microposts.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This micropost really ties the room together"
    assert_difference '@user.microposts.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
      @user.reload
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.page(1).first
    assert_difference '@user.microposts.count', -1 do
      delete micropost_path(first_micropost)
      @user.reload
    end
    # Visit different user (no delete links)
    get user_path(@user1)
    assert_select 'a', text: 'delete', count: 0
  end

  def teardown
	  @user.destroy
      @user1.destroy
  end
end
