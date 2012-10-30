require 'mws'

class SubmitFeed < Job

  def perform
    queue, tasks = select_queue
    return if queue.nil?
    queue.last_drain = Time.now
    queue.save
    api = Mws::Apis::Feeds::TargetedApi.new Mws.connection.feeds, queue.merchant, queue.feed_type
    tx = api.submit(tasks)
    FeedTransaction.transaction do
      transaction = FeedTransaction.create identifier: tx.id, state: :running
      tasks.zip(tx.items) do | task, item |
        task.transaction = transaction
        task.index = item.id
        task.save
      end
    end
  end

  private

  def select_queue
    queues = FeedQueue.order(:priority)
    circle(queues, start_index(queues)) do | queue |
      tasks = queue.tasks.where(<<-SQL
        transaction_id is NULL and
        not exists ( 
          select task_id from #{FeedTaskDependency.table_name} 
          where task_id = #{FeedTask.table_name}.id
        )
        SQL
      ).order(:created_at).limit(queue.batch_size)
      return [ queue, tasks ] unless tasks.empty?
    end
    return [ nil, nil ]
  end

  def start_index(queues)
    last_drained = queues.max do | a, b | 
      return -1 if a.last_drain.nil?
      return 1 if b.last_drain.nil?
      a.last_drain <=> b.last_drain
    end
    queues.find_index(last_drained) + 1
  end

  def circle(collection, start=0)
    start.upto(start + collection.size - 1) do | index |
      yield collection[index % collection.size]
    end
  end

end