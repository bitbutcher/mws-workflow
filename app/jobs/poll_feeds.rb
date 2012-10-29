class PollFeeds < Job

  def perform
    tasks = FeedTask.where state: :dequeued
    unless tasks.empty?
      Mws.connection.feeds.list(ids: tasks.map { | task | task.transaction_id }).each do | info |
        if info.status == :done
          task = tasks.find { | task | task.transaction_id == info.id.to_i }
          task.status = :complete
          task.save
        end
      end
    end
  end

end
