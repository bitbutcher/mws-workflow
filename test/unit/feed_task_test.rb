require 'test_helper'

class FeedTaskTest < ActiveSupport::TestCase

 context '.create' do

  queue = FeedQueue.create! name: :product, feed_type: :product, merchant: '123123213', priority: 1, batch_size: 100

  should 'be able to create a valid task' do
    task = FeedTask.create! sku: '123343', queue: queue, operation_type: :update, body: '<Resource/>'
    assert_not_nil task
    assert task.valid?
    assert_equal '123343', task.sku
    assert_equal queue, task.queue
    assert_equal :update, task.operation_type
    assert_equal '<Resource/>', task.body
  end

  should 'require a sku' do
    assert_raises ActiveRecord::RecordInvalid do
      FeedTask.create! queue: queue, operation_type: :update, body: '<Resource/>'
    end
  end

  should 'require a queue' do
    assert_raises ActiveRecord::RecordInvalid do
      FeedTask.create! sku: '123343', operation_type: :update, body: '<Resource/>'
    end
  end

  should 'require an operation type' do
    assert_raises ActiveRecord::RecordInvalid do
      FeedTask.create! sku: '123343', queue: queue, body: '<Resource/>'
    end
  end  

  should 'require a valid operation type' do
    assert_raises ActiveRecord::RecordInvalid do
      FeedTask.create! sku: '123343', queue: queue, operation_type: :some_super_cool_operation_type, body: '<Resource/>'
    end
    Mws::Feed::Message::OperationType.syms.each do | sym |
      assert_equal sym, (FeedTask.create! sku: '123343', queue: queue, operation_type: sym, body: '<Resource/>').operation_type
    end
  end

  should 'require a body' do
    assert_raises ActiveRecord::RecordInvalid do
      FeedTask.create! sku: '123343', queue: queue, operation_type: :update
    end
  end 

 end

end
