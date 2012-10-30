class GetFeedResult < Job

  def perform
    tx = FeedTransaction.where(state: :complete).order(:created_at).first
    return if tx.nil?
    result = Mws.connection.feeds.get(tx.identifier)
    if result.message_count == result.message_count(:success)
      tx.tasks.each do | task |
        FeedTaskDependency.where(dependency_id: task).delete_all
        task.delete
      end
      tx.state = :successful
    else 
      tx.state = :failed
    end
    tx.save
  end

end