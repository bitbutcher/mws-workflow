require File.expand_path('../environment', __FILE__)
require 'clockwork'

module Clockwork
  handler do |job|
    puts "Running #{job}"
    job, options = normalize_job job
    job.enqueue options
  end

  def normalize_job(job)
    job = [job].flatten
    job << {} if job.size < 2
    job
  end
  
  # The schedule:
  merchant = ENV['MWS_MERCHANT']

  every 10.seconds, [ SubmitFeed, { merchant: merchant } ]
  every 2.minutes, [ Charger, {
    merchant: merchant,
    operation: 'SubmitFeed'
  }]

  every 30.seconds, [ PollFeeds, { merchant: merchant } ]
  every 45.seconds, [ Charger, {
    merchant: merchant,
    operation: 'PollFeeds'
  }]

  every 10.seconds, [ GetFeedResult, { merchant: merchant } ]
  every 1.minute, [ Charger, {
    merchant: merchant,
    operation: 'GetFeedResult'
  }]

end
