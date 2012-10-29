require File.expand_path('../environment', __FILE__)
require 'clockwork'

module Clockwork
  handler do |job|
    puts "Running #{job}"
    job.enqueue
  end
  
  # The schedule:
  every 45.seconds, PollFeeds
  every 1.minute, GetFeedResult
  every 2.minutes, SubmitFeed
end
