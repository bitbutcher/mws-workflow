class PollFeeds < Job

  def initialize(options)
    @merchant = options[:merchant]
    @task = [ @merchant, self.class.name.split('::').first ].join ':'
  end

  def perform
    txs = FeedTransaction.running
    return if txs.empty? or Battery.discharge(@task).nil?
    Mws.connection.feeds.list(ids: txs.map { | tx | tx.identifier }).each do | info |
      if info.status == :done
        tx = txs.find { |tx| tx.identifier == info.id.to_i }
        tx.state = :complete
        tx.save
      end
    end
  end

end
