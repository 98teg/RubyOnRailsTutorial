require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @micropost = @user.microposts.create(content: "Lorem ipsum", created_at: 30.minutes.ago)

    @user1 = User.create(name: "Example User", email: "user1@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @micropost1 = @user1.microposts.create(content: "Lorem ipsum", created_at: 30.minutes.ago)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    log_in_as(@user, password: "foobar")
    assert_no_difference '@user1.microposts.count' do
      delete micropost_path(@micropost1)
    end
    assert_redirected_to root_url
  end


  def teardown
    @user.destroy
    @user1.destroy
  end
end
