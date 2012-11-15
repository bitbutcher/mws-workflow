require 'test_helper'

class TestResource

  attr_reader :sku

  def initialize(sku)
    @sku = sku
  end

  def to_xml
    '<Resource/>'
  end

end

class FeedQueueTest < ActiveSupport::TestCase

  context '.create' do
  
    should 'be able to create a valid product' do
      queue = FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      assert queue.valid?
      assert_equal :product, queue.name
      assert_equal :product, queue.feed_type
      assert_equal '12124asdasdasd', queue.merchant
      assert_equal 1, queue.priority
      assert_equal 100, queue.batch_size
    end    

    should 'require a name' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      end
    end

    should 'require a feed type' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      end
    end

    should 'require a valid feed type' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :super_cool_feed_type, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      end
      Mws::Feed::Type.syms.each do | sym |
        assert_equal sym, FeedQueue.create!(name: :product, feed_type: sym, merchant: '12124asdasdasd', priority: 1, batch_size: 100).feed_type
      end
    end

    should 'require a unique feed type per merchant' do
      FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      end
      assert FeedQueue.create!(name: :product, feed_type: :product, merchant: 'asdasdasd12124', priority: 1, batch_size: 100).valid?
    end    

    should 'require a merchant' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, priority: 1, batch_size: 100
      end
    end

    should 'require a priority' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', batch_size: 100
      end
    end

    should 'require an integer priority' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 'f', batch_size: 100
      end
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: :f, batch_size: 100
      end
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1.0, batch_size: 100
      end
      FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: '1', batch_size: 100
      FeedQueue.create! name: :image, feed_type: :image, merchant: '12124asdasdasd', priority: 1, batch_size: 100
    end

    should 'require a batch_size' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1
      end
    end

    should 'require an integer batch_size' do
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 'f'
      end
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: :f
      end
      assert_raises ActiveRecord::RecordInvalid do
        FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100.0
      end
      FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: '100'
      FeedQueue.create! name: :imgage, feed_type: :image, merchant: '12124asdasdasd', priority: 1, batch_size: 100
    end

  end

  context 'scopes' do

    should 'support lookup via a feed type scope' do
      product_q = FeedQueue.create! name: :product, feed_type: :product, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      image_q = FeedQueue.create! name: :image, feed_type: :image, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      price_q = FeedQueue.create! name: :price, feed_type: :price, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      override_q = FeedQueue.create! name: :override, feed_type: :override, merchant: '12124asdasdasd', priority: 1, batch_size: 100
      inventory_qs = []
      inventory_qs << FeedQueue.create!(name: :inventory, feed_type: :inventory, merchant: '12124asdasdasd', priority: 1, batch_size: 100)
      inventory_qs << FeedQueue.create!(name: :inventory, feed_type: :inventory, merchant: 'dsfasfdasf', priority: 1, batch_size: 100)
      inventory_qs << FeedQueue.create!(name: :inventory, feed_type: :inventory, merchant: 'adfasdf', priority: 1, batch_size: 100)

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
      product_q1 = FeedQueue.create! name: :product, feed_type: :product, merchant: merchant1, priority: 1, batch_size: 100
      product_q2 = FeedQueue.create! name: :product, feed_type: :product, merchant: merchant2, priority: 1, batch_size: 100
      product_q3 = FeedQueue.create! name: :product, feed_type: :product, merchant: merchant3, priority: 1, batch_size: 100
      image_q = FeedQueue.create! name: :image, feed_type: :image, merchant: merchant1, priority: 1, batch_size: 100
      price_q = FeedQueue.create! name: :price, feed_type: :price, merchant: merchant1, priority: 1, batch_size: 100
      price_q2 = FeedQueue.create! name: :price, feed_type: :price, merchant: merchant2, priority: 1, batch_size: 100
      override_q = FeedQueue.create! name: :override, feed_type: :override, merchant: merchant1, priority: 1, batch_size: 100
      inventory_q1 = FeedQueue.create!(name: :inventory, feed_type: :inventory, merchant: merchant1, priority: 1, batch_size: 100)
      inventory_q2 = FeedQueue.create!(name: :inventory, feed_type: :inventory, merchant: merchant2, priority: 1, batch_size: 100)
      inventory_q3 = FeedQueue.create!(name: :inventory, feed_type: :inventory, merchant: merchant3, priority: 1, batch_size: 100)

      assert_contains_all [product_q1, image_q, price_q, override_q, inventory_q1], FeedQueue.merchant(merchant1)
      assert_contains_all [product_q2, price_q2, inventory_q2], FeedQueue.merchant(merchant2)
      assert_contains_all [product_q3, inventory_q3], FeedQueue.merchant(merchant3)
      assert_empty FeedQueue.merchant('blahh')
    end

  end

  context '#enqueue' do

    should 'support enquing a resource update' do 
      queue = FeedQueue.create! name: :product, feed_type: :product, merchant: 'adfasdf', priority: 1, batch_size: 100
      task = queue.enqueue_update TestResource.new('1234')
      assert_not_nil task 
      assert_equal queue, task.queue
      assert_equal :update, task.operation_type
    end

    should 'support enquing a resource delete' do 
      queue = FeedQueue.create! name: :product, feed_type: :product, merchant: 'adfasdf', priority: 1, batch_size: 100
      task = queue.enqueue_delete TestResource.new('1234')
      assert_not_nil task 
      assert_equal queue, task.queue
      assert_equal :delete, task.operation_type
    end

  end

  context '#tasks' do

    should 'returns queued tasks' do
      queue = FeedQueue.new name: :product, feed_type: :product, merchant: 'adfasdf', priority: 1, batch_size: 100
      tasks = []
      tasks << queue.enqueue_update(TestResource.new('1234'))
      tasks << queue.enqueue_update(TestResource.new('123456'))
      tasks << queue.enqueue_delete(TestResource.new('12345678'))

      assert_contains_all tasks, queue.tasks

    end

    should 'returns ready and pending tasks' do
      queue = FeedQueue.new name: :product, feed_type: :product, merchant: 'adfasdf', priority: 1, batch_size: 100
      tasks = []
      tasks << queue.enqueue_update(TestResource.new('1234'))
      tasks << queue.enqueue_update(TestResource.new('123456'))
      tasks << queue.enqueue_delete(TestResource.new('12345678'), tasks[0])


      assert_contains_all [tasks[0], tasks[1]], queue.tasks.ready
      assert_contains_all [tasks[2]], queue.tasks.pending
    end

  end

  def assert_contains_all(expected, actual)
    tmp = expected.dup
    actual.each do | it |
      assert_contains expected, it
      tmp.delete it
    end
    assert_empty tmp
  end

end
