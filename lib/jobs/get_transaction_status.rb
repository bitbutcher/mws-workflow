module Jobs

  class GetTransactionStatus

    def self.run
      puts 'Running Job'
      Mws.connection.feeds.list.each { | info | puts info.inspect }
    end

  end

end