module QC
  module Conn
    def connection
      # We want queue operations to share a transaction with other ActiveRecord operations.
      # This is a hack. We should keep an eye on it as we develop & make sure it's well-behaved. -PPC

      # This is also critical to preventing race conditions with GetOrdersJob, because
      # transactions are not distributed across database connections.
      ActiveRecord::Base.connection.instance_variable_get('@connection')
    end
  end
end