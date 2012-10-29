class GetFeedResult < Job

  def perform
    task = FeedTask.where(state: :complete).first
    unless task.nil?
      result = Mws.connection.feeds.get(task.transaction_id)
      if result.message_count == result.message_count(:success)
        FeedTaskDependency.where(dependency_id: task).delete_all
        task.delete
      else 
        # Handle error....
      end
    end
  end

end