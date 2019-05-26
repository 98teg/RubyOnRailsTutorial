require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user1 = User.new(name: "Example User", email: "user1@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
    @user1.save
    @user2 = User.new(name: "Example User", email: "user2@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
    @user2.save
    @user3 = User.new(name: "Example User", email: "user3@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
    @user3.save
    @user4 = User.new(name: "Example User", email: "user4@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
    @user4.save

    @user1.follow(@user2)
    @user1.follow(@user3)
    @user2.follow(@user1)
    @user4.follow(@user1)

    log_in_as(@user1, password: "foobar")
  end

  test "following page" do
    get following_user_path(@user1)
    assert_not @user1.following.empty?
    assert_match @user1.following.count.to_s, response.body
    @user1.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user1)
    assert_not @user1.followers.empty?
    assert_match @user1.followers.count.to_s, response.body
    @user1.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user the standard way" do
    assert_difference '@user1.following_count', 1 do
      post relationships_path, params: { followed_id: @user2.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference '@user1.following_count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @user2.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user1.follow(@user2)
    relationship = @user1.active_relationships.find_by(followed_id: @user2.id)
    assert_difference '@user1.following_count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user1.follow(@user2)
    relationship = @user1.active_relationships.find_by(followed_id: @user2.id)
    assert_difference '@user1.following_count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  def teardown
    @user1.destroy
    @user2.destroy
    @user3.destroy
    @user4.destroy
  end
end
