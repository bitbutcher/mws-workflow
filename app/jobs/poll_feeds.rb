class PollFeeds < Job

  def perform
    txs = FeedTransaction.running
    return if txs.empty?
    Mws.connection.feeds.list(ids: txs.map { | tx | tx.identifier }).each do | info |
      if info.status == :done
        tx = txs.find { |tx| tx.identifier == info.id.to_i }
        tx.state = :complete
        tx.save
      end
    end
  end

end
