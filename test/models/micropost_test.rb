require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @micropost = @user.microposts.build(content: "Lorem ipsum", created_at: 30.minutes.ago)
    @micropost1 = @user.microposts.build(content: "Lorem ipsum 1", created_at: 10.minutes.ago)
    @micropost2 = @user.microposts.build(content: "Lorem ipsum 2", created_at: 2.years.ago)
    @micropost3 = @user.microposts.build(content: "Lorem ipsum 3", created_at: 3.years.ago)
    @micropost4 = @user.microposts.build(content: "Lorem ipsum 4", created_at: Time.zone.now)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal @user.microposts.order_by([[:created_at, :desc]]).first, @user.microposts.scoped.first
  end
end
