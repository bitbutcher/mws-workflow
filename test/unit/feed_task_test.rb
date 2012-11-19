require 'test_helper'

class FeedTaskTest < ActiveSupport::TestCase

  context '.create' do

    should 'be able to create a valid task' do
      task = create :feed_task
      assert_not_nil task
      assert task.valid?
      assert_equal '1232323', task.sku
      assert_not_nil task.queue
      assert_equal :update, task.operation_type
      assert_equal '<Resource/>', task.body
    end

    should 'require a sku' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, sku: nil
      end
    end

    should 'require a queue' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, queue: nil
      end
    end

    should 'require an operation type' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, operation_type: nil
      end
    end  

    should 'require a valid operation type' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, operation_type: :some_super_cool_operation_type
      end
      Mws::Feed::Message::OperationType.syms.each do | sym |
        assert_equal sym, (create :feed_task, operation_type: sym).operation_type
      end
    end

    should 'require a body' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, body: nil
      end
    end 

    should 'require a numeric message index' do
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, index: 'f'
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, index: :f
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, index: 1.0
      end
      create :feed_task, index: '1'
      create :feed_task, index: 2
    end 

    should 'require a unique index per transaction' do
      transaction = create :feed_transaction
      create :feed_task, transaction: transaction, index: 1
      assert_raises ActiveRecord::RecordInvalid do
        create :feed_task, transaction: transaction, index: 1
      end
    end

  end


  context '#state' do

    should 'return :ready state with no dependencies' do
      assert_equal :ready, create(:feed_task).state
    end

    should 'return :pending when dependencies are defined' do
      task = create :feed_task
      task.dependencies << create(:feed_task)
      task.dependencies << create(:feed_task)
      assert_equal :pending, task.state
    end

    should 'return :ready state after dependencies are removed' do
      task = create :feed_task
      task.dependencies << create(:feed_task)
      task.dependencies << create(:feed_task)
      assert_equal :pending, task.state
      task.dependencies.delete_all
      assert_equal :ready, task.state
    end

    should 'return :failed with a failure is present' do
      assert_equal :failed, create(:feed_task, failure: 'something happened').state
    end

    should 'return its transaction state if present' do
      assert_equal :running, create(:feed_task_with_running_transaction).state
      assert_equal :complete, create(:feed_task_with_complete_transaction).state
      assert_equal :successful, create(:feed_task_with_successful_transaction).state
      assert_equal :failed, create(:feed_task_with_failed_transaction).state
    end

  end

  context 'scopes' do

    setup do
      @ready = [ create(:feed_task), create(:feed_task) ]
      @pending = [ create(:feed_task), create(:feed_task) ]
      @pending.first.dependencies << @ready.first
      @pending.last.dependencies << @ready.last
      @running = [ create(:feed_task_with_running_transaction), create(:feed_task_with_running_transaction) ]
      @complete = [ create(:feed_task_with_complete_transaction), create(:feed_task_with_complete_transaction) ]
      @successful = [ create(:feed_task_with_successful_transaction), create(:feed_task_with_successful_transaction) ]
      @failed = [ create(:feed_task_with_failure), create(:feed_task_with_failure) ]
    end

    context '#ready' do

      should 'return all ready tasks' do
        assert_contains_all @ready, FeedTask.ready
      end

    end

    context '#pending' do

      should 'return all pending tasks' do
        assert_contains_all @pending, FeedTask.pending
      end

    end

    context '#running' do

      should 'return all running tasks' do
        assert_contains_all @running, FeedTask.running
      end

    end

    context '#complete' do

      should 'return all complete tasks' do
        assert_contains_all @complete, FeedTask.complete
      end

    end

    context '#successful' do

      should 'return all successful tasks' do
        assert_contains_all @successful, FeedTask.successful
      end

    end

    context '#failed' do

      should 'return all failed tasks' do
        assert_contains_all @failed, FeedTask.failed
      end

    end

  end

  context '.enqueue' do

    should 'be able to enqueue to a given queue' do
      queue = create :feed_queue
      resource = TestResource.new '121212'
      task = FeedTask.enqueue queue, resource, :update
      assert_not_nil task
      assert_equal queue, task.queue
      assert_equal :update, task.operation_type
      assert_not_nil task.body
      assert_equal :ready, task.state
    end

    should 'be able to enqueue to a given queue with dependencies' do
      queue = create :feed_queue
      resource = TestResource.new '121212'
      deps = [ create(:feed_task), create(:feed_task) ]
      task = FeedTask.enqueue queue, resource, :update, *deps
      assert_not_nil task
      assert_equal queue, task.queue
      assert_equal :update, task.operation_type
      assert_not_nil task.body
      assert_equal :pending, task.state
      assert_contains_all deps, task.dependencies
    end

  end

  context '#to_xml' do

    should 'return the xml body' do

      assert_equal '<Resource/>', create(:feed_task, body: '<Resource/>').to_xml

    end

  end

  context '#as_json' do

    should 'return simple json' do
      task = create :feed_task, id: 999, queue: create(:feed_queue, id: 777)
      assert_equal({
        'failure' => nil, 
        'id' =>  999, 
        'index' =>  nil, 
        'operation_type' =>  :update, 
        'sku' =>  '1232323', 
        state:  :ready, 
        dependency_ids:  [], 
        queue:  {
          'feed_type' =>  :product, 
          'id' =>  777, 
          'name' => :product
        }
      }, task.as_json)
    end

    should 'return json with dependency_ids' do
      task = create :feed_task, id: 999, queue: create(:feed_queue, id: 777)
      task.dependencies << create(:feed_task, id: 1)
      task.dependencies << create(:feed_task, id: 2)
      assert_equal({
        'failure' => nil, 
        'id' =>  999, 
        'index' =>  nil, 
        'operation_type' =>  :update, 
        'sku' =>  '1232323', 
        state:  :pending, 
        dependency_ids:  [1, 2], 
        queue:  {
          'feed_type' =>  :product, 
          'id' =>  777, 
          'name' => :product
        }
      }, task.as_json)
    end

    should 'return full json' do
      task = create :feed_task, id: 999, index: 1, 
        transaction: create(:feed_transaction, id: 888, identifier: 1231312), 
        queue: create(:feed_queue, id: 777)
      assert_equal({
        'failure' => nil, 
        'id' =>  999, 
        'index' => 1, 
        'operation_type' =>  :update, 
        'sku' =>  '1232323', 
        state:  :running, 
        dependency_ids:  [], 
        queue:  {
          'feed_type' =>  :product, 
          'id' =>  777, 
          'name' => :product
        },
        transaction: {
          "failure" => nil, 
          "id" => 888, 
          "identifier" => 1231312, 
          "state"=>:running
        }
      }, task.as_json)
    end

  end

end
