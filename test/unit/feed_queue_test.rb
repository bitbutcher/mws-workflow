require 'test_helper'

class FeedQueueTest < ActiveSupport::TestCase

  context '.create' do
  
    should 'be able to create a valid product' do
      queue = create :feed_queue
      assert queue.valid?
      assert_equal :product, queue.name
      assert_equal :product, queue.feed_type
      assert_equal '123123213', queue.merchant
      assert_equal 1, queue.priority
      assert_equal 100, queue.batch_size
    end    

    should 'require a name' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, name: nil
      end
    end

    should 'require a feed type' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, feed_type: nil
      end
    end

    should 'require a valid feed type' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, feed_type: :super_cool_feed_type
      end
      Mws::Feed::Type.syms.each do | sym |
        assert_equal sym, create(:feed_queue, feed_type: sym).feed_type
      end
    end

    should 'require a unique feed type per merchant' do
      create :feed_queue
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue
      end
      create :feed_queue, merchant: 'asdasdasd12124'
    end    

    should 'require a merchant' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, merchant: nil
      end
    end

    should 'require a priority' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, priority: nil
      end
    end

    should 'require an integer priority' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, priority: 'f'
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, priority: :f
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, priority: 1.0
      end
      create :feed_queue, priority: '1'
      create :image_queue, priority: 1
    end

    should 'require a batch_size' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, batch_size: nil
      end
    end

    should 'require an integer batch_size' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, batch_size: 'f'
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, batch_size: :f
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_queue, batch_size: 100.0
      end
      create :feed_queue, batch_size: '100'
      create :image_queue, batch_size: 100
    end

  end

  context 'scopes' do

    should 'support lookup via a feed type scope' do
      product_q = create :product_queue
      image_q = create :image_queue
      price_q = create :price_queue
      override_q = create :override_queue
      inventory_qs = []
      inventory_qs << create(:inventory_queue, merchant: '12124asdasdasd')
      inventory_qs << create(:inventory_queue, merchant: 'dsfasfdasf')
      inventory_qs << create(:inventory_queue, merchant: 'adfasdf')

       assert_equal product_q, FeedQueue.type(:product).first
       assert_equal image_q, FeedQueue.type(:image).first
       assert_equal price_q, FeedQueue.type(:price).first
       assert_equal override_q, FeedQueue.type(:override).first
       assert_equal inventory_qs, FeedQueue.type(:inventory)

       assert_empty FeedQueue.type(:order)
    end

    should 'support lookup via merchant' do
      merchant1 = '12124asdasdasd'
      merchant2 = 'dsfasfdasf'
      merchant3 = 'adfasdf'
      product_q1 = create :product_queue, merchant: merchant1
      product_q2 = create :product_queue, merchant: merchant2
      product_q3 = create :product_queue,  merchant: merchant3
      image_q = create :image_queue, merchant: merchant1
      price_q = create :price_queue, merchant: merchant1
      price_q2 = create :price_queue, merchant: merchant2
      override_q = create :override_queue, merchant: merchant1
      inventory_q1 = create :inventory_queue,  merchant: merchant1
      inventory_q2 = create :inventory_queue,  merchant: merchant2
      inventory_q3 = create :inventory_queue,  merchant: merchant3

      assert_contains_all [product_q1, image_q, price_q, override_q, inventory_q1], FeedQueue.merchant(merchant1)
      assert_contains_all [product_q2, price_q2, inventory_q2], FeedQueue.merchant(merchant2)
      assert_contains_all [product_q3, inventory_q3], FeedQueue.merchant(merchant3)
      assert_empty FeedQueue.merchant('blahh')
    end

    should 'support chaining scopes' do

      merchant1 = '12124asdasdasd'
      merchant2 = 'dsfasfdasf'
      merchant3 = 'adfasdf'
      product_q1 = create :product_queue, merchant: merchant1
      product_q2 = create :product_queue, merchant: merchant2
      product_q3 = create :product_queue,  merchant: merchant3
      image_q = create :image_queue, merchant: merchant1
      price_q = create :price_queue, merchant: merchant1
      price_q2 = create :price_queue, merchant: merchant2
      override_q = create :override_queue, merchant: merchant1
      inventory_q1 = create :inventory_queue,  merchant: merchant1
      inventory_q2 = create :inventory_queue,  merchant: merchant2
      inventory_q3 = create :inventory_queue,  merchant: merchant3

      assert_equal [product_q1], FeedQueue.merchant(merchant1).type(:product)
      assert_equal [inventory_q1], FeedQueue.merchant(merchant1).type(:inventory)

    end

  end

  context '#enqueue' do
    setup do
      @queue = create :feed_queue
    end

    should 'support enquing a resource update' do 
      task = @queue.enqueue_update TestResource.new('1234')
      assert_not_nil task 
      assert_equal @queue, task.queue
      assert_equal :update, task.operation_type
    end

    should 'support enquing a resource delete' do 
      task = @queue.enqueue_delete TestResource.new('1234')
      assert_not_nil task 
      assert_equal @queue, task.queue
      assert_equal :delete, task.operation_type
    end

  end

  context '#tasks' do
    setup do
      @queue = create :feed_queue
    end

    should 'returns queued tasks' do
      tasks = []
      tasks << @queue.enqueue_update(TestResource.new('1234'))
      tasks << @queue.enqueue_update(TestResource.new('123456'))
      tasks << @queue.enqueue_delete(TestResource.new('12345678'))

      assert_contains_all tasks, @queue.tasks

    end

    should 'returns ready and pending tasks' do
      tasks = []
      tasks << @queue.enqueue_update(TestResource.new('1234'))
      tasks << @queue.enqueue_update(TestResource.new('123456'))
      tasks << @queue.enqueue_delete(TestResource.new('12345678'), tasks[0])

      assert_contains_all [tasks[0], tasks[1]], @queue.tasks.ready
      assert_contains_all [tasks[2]], @queue.tasks.pending
    end

  end

end
