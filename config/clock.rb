require File.expand_path('../environment', __FILE__)
require 'clockwork'

module Clockwork
  handler do |job|
    puts "Running #{job}"
    job.run
  end
  
  # The schedule:
  every 1.minute, Jobs::GetTransactionStatus
end
