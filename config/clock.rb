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
  every 45.seconds, PollFeeds
  every 1.minute, GetFeedResult
  every 2.minutes, [SubmitFeed, {merchant: ENV['MWS_MERCHANT']}]
end
