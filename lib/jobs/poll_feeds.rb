module Jobs

  class PollFeeds < Job

    def perform
      Mws.connection.feeds.list.each { | info | Rails.info info.inspect }
    end

  end

end