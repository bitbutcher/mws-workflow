require 'test_helper'

class FeedTaskTest < ActiveSupport::TestCase

  context '.create' do

    should 'be able to create a valid transaction' do
      transaction = create :feed_transaction
      assert_not_nil transaction
      assert transaction.valid?
      assert_not_nil transaction.identifier
      assert_equal :running, transaction.state
    end

    should 'require an identifier' do 
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_transaction, identifier: nil
      end
    end

    should 'require a numeric identifier' do 
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_transaction, identifier: 'foobar'
      end
    end

    should 'require a unique identifier' do 
      create :feed_transaction, identifier: 1234
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_transaction, identifier: 1234
      end
    end

    should 'require a state' do 
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_transaction, state: nil
      end
    end

    should 'require a valid state' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_transaction, state: :not_even_created
      end

      identifier = 1234
      FeedTransaction::States.each do | state |
        assert_equal state, create(:feed_transaction, identifier: identifier, state: state).state
        identifier += 1
      end
    end
  end

end