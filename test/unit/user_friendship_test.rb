require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:friend)

  test "that creating a friendship works without raising and exception" do
  	assert_nothing_raised do 
  		UserFriendship.create user: users(:david), friend: users(:mike)
  	end
  end

  test "that creating a friendship based on user id and friend id works" do 
  	UserFriendship.create user_id: users(:david).id, friend_id: users(:mike).id 
  	assert users(:david).pending_friends.include?(users(:mike))
  end

  context "a new instance" do
    setup do
      @user_friendship = UserFriendship.new user: users(:david), friend: users(:mike)
    end

    should "have a pending state" do
      assert_equal 'pending', @user_friendship.state
    end

    context "#send_request_email" do
      setup do
        @user_friendship = UserFriendship.create user: users(:david), friend: users(:mike)
      end

      should "send an email" do
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          @user_friendship.send_request_email
        end
      end
    end

    context "#accept!" do
      setup do
        @user_friendship = UserFriendship.create user: users(:david), friend: users(:mike)
      end

      should "set the state to accepted" do 
        @user_friendship.accept!
        assert_equal "accepted", @user_friendship.state
      end

      should "send an acceptance email" do
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          @user_friendship.accept!
        end
      end

      should "inclide the friend in the list of friends" do
        @user_friendship.accept!
        users(:david).friends.reload
        assert users(:david).friends.include?(users(:mike))
      end
    end

    context ".request" do
      should "create two user friendships" do 
        assert_difference "UserFriendship.count", 2 do
          UserFriendship.request(users(:david), users(:mike))
        end
      end

      should "send a friend request email" do
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          UserFriendship.request(users(:david), users(:mike))
        end
      end
    end
  end
end
