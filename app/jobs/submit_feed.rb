require 'mws'

class SubmitFeed < Job

  def perform
    queue, tasks = select_queue
    return if queue.nil?
    api = Mws::Apis::Feeds::TargetedApi.new Mws.connection.feeds, queue.merchant, queue.name.to_sym
    api.submit(tasks)
  end

  private:

  def select_queue
    queues = FeedQueue.order(:priority)
    circle(queues, start_index(queues)) do | queue |
      tasks = queue.tasks.where(state: :enqueued).order(:enqueued).limit(queue.batch_size)
      return [ queue, tasks ] unless tasks.empty?
    end
  end

  def get_start_index(queues)
    last_drained = queues.min_by { |it| it.last_drain }
    queues.find_index(last_drained) + 1
  end

  def circle(collection, start=0)
    start.upto(start + collection.size - 1) do | index |
      yield collection[index % collection.size]
    end
  end

end