require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @user = User.create(name: "Example User", email: "user@example.com",
                        password: "foobar", password_confirmation: "foobar",
                        activated: true, activated_at: Time.zone.now)

    @user1 = User.create(name: "Example User", email: "user1@example.com",
                         password: "foobar", password_confirmation: "foobar",
                         activated: true, activated_at: Time.zone.now)

    @relationship = Relationship.new(follower_id: @user.id,
                                     followed_id: @user1.id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  def teardown
    @user.destroy
    @user1.destroy
  end
end
