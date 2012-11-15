class GetFeedResult < Job

  def initialize(options)
    @merchant = options[:merchant]
    @device = [ self.class.name.split('::').last, @merchant ].join ':'
  end

  def perform
    tx = FeedTransaction.complete.order(:created_at).first
    return if tx.nil? or Battery.discharge(@device).nil?
    result = Mws.connection.feeds.get(tx.identifier)
    FeedTransaction.transaction do
      tx.state = :successful
      if result.messages_processed == 0
        tx.state = :failed
        tx.failure = result.response_for(1).description
        tx.tasks.each do | task |
          task.failure = tx.failure
          task.save
        end
      else 
        Rails.logger.warn 'Message count is not the same as task count.' unless tx.tasks.size == result.messages_processed
        tx.tasks.each do | task |
          response = result.response_for task.index
          if response.nil?
            FeedTaskDependency.depend_on(task).delete_all
            # task.delete
          else 
            tx.state = :has_failures
            task.failure = response.description
            task.save
          end
        end
      end
      tx.save
    end
  end

end