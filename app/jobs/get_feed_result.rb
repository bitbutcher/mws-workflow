class GetFeedResult < Job

  def initialize(options)
    @merchant = options[:merchant]
    @device = [ self.class.name.split('::').last, @merchant ].join ':'
  end

  def perform
    tx = FeedTransaction.complete.order(:created_at).first
    return if tx.nil? or Battery.discharge(@device).nil?
    result = Mws.connection.feeds.get(tx.identifier)
    Rails.logger.info "\n\n\n\n"
    Rails.logger.info "Result: #{result.inspect}"
    Rails.logger.info "\n\n\n\n"
    FeedTransaction.transaction do
      tx.state = :successful
      if result.message_count == 0
        tx.state = :failed
        tx.failure = result.message_for(1).description
        tx.tasks.each do | task |
          task.failure = tx.failure
          task.save
        end
      else 
        Rails.logger.warn 'Message count is not the same as task count.' unless tx.tasks.size == result.message_count
        tx.tasks.each do | task |
          message_result = result.message_for task.index
          if message_result.nil?
            FeedTaskDependency.depend_on(task).delete_all
            # task.delete
          else 
            tx.state = :has_failures
            task.failure = message_result.description
            task.save
          end
        end
      end
      tx.save
    end
  end

end