class GetFeedResult < Job

  def perform
    tx = FeedTransaction.complete.order(:created_at).first
    return if tx.nil?
    result = Mws.connection.feeds.get(tx.identifier)
    if result.message_count == result.message_count(:success)
      tx.tasks.each do | task |
        FeedTaskDependency.depend_on(task).delete_all
        task.delete
      end
      tx.state = :successful
    else
      # TODO add failure messages to the appropriate tasks
      tx.state = :has_failures
    end
    tx.save
  end

end