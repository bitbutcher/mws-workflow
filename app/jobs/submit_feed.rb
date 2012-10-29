require 'mws'

class SubmitFeed < Job

  def perform
    queue, tasks = select_queue
    return if queue.nil?
    api = Mws::Apis::Feeds::TargetedApi.new Mws.connection.feeds, queue.merchant, queue.name.to_sym
    api.submit(tasks)
  end

  def select_queue
    queues = FeedQueue.order(:priority)    
    last_drained = queues.min_by { |it| it.last_drain }
    start_index = queues.find_index(last_drained) + 1
    start_index.upto(start_index + queues.size - 1) do | index |
      queue = queues[index % queues.size]
      tasks = queue.tasks.where(state: :enqueued).order(:enqueued).limit(queue.batch_size)
      return [ queue, tasks ] unless tasks.empty?
    end
  end

end