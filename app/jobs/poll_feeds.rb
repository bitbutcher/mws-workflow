class PollFeeds < Job

  def initialize(options)
    @merchant = options[:merchant]
    @device = [ self.class.name.split('::').last, @merchant ].join ':'
  end

  def perform
    txs = FeedTransaction.running
    return if txs.empty? or Battery.discharge(@device).nil?
    Mws.connection.feeds.list(ids: txs.map { | tx | tx.identifier }).each do | info |
      if info.status == :done
        tx = txs.find { |tx| tx.identifier == info.id.to_i }
        tx.state = :complete
        tx.save
      end
    end
  end

end
