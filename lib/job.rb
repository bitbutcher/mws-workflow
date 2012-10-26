# The base class for queueable units of work. Subclassess should override the #perform instance method.
#
# A job may create other jobs by calling #enqueue. The second arg of enqueue is an options hash, which
# is passed to the new job via the "opts" accessor. The :payload option receives a little special treatment:
# it's wrapped in a SafeWalker, and is directly accessible through the "payload" convenience accessor
# (as well as through opts[:payload]).
#
# Example:
#
#   class FooJob < Job
#     def perform
#       resp = do_some_request.response
#       enqueue BarJob, payload: resp, some_option: 'whatever'
#     end
#   end
#
#   class BarJob < Job
#     def perform
#       puts opts[:some_option]
#       puts payload.orders.line_items.thinger
#     end
#   end
#
class Job
  class << self
    # Enqueues a new job of this class for later processing.
    #
    # job_opts:  A JSON-encodable hash. job_opts[:payload] may be a SafeWalker.
    #
    def enqueue(job_opts = {})
      puts "Perf"
      QC.enqueue "#{self.name}.perform", encode_opts(job_opts)
    end
    
    # Worker calls this method
    def perform(opts = {})
      logger.info "#{self} running..."
      self.new(decode_opts(opts)).perform
      logger.info "#{self} done."
    end
  
    def encode_opts(opts)
      opts[:payload] = SafeWalker.unwrap(opts[:payload]) if opts[:payload]
      opts = opts.with_indifferent_access  # deep-stringifies keys, making them JSON-friendly
      opts
    end
  
    def decode_opts(opts)
      opts = opts.with_indifferent_access
      opts[:payload] = SafeWalker.wrap(opts[:payload]) if opts[:payload]
      opts
    end
    
    def retry_after(*schedule)
      self.retry_schedule = schedule
    end
    
    def no_retry
      self.retry_schedule = []
    end

    def retry_every(period, opts = {})
      time_limit = opts[:for]
      period_inc = opts[:increasing_by] || 0
      raise "retry_every requires a :for option, e.g.:  retry_every 2.minutes, for: 1.hour" unless time_limit
      raise "negative increasing_by not allowed" if period_inc < 0
      
      schedule = []
      elapsed = period
      while elapsed <= time_limit
        schedule << period
        period += period_inc if period_inc
        elapsed += period
      end
      
      retry_after *schedule
    end

    def after_all_retries_failed(method_name)
      self.method_to_call_after_all_retries_failed = method_name
    end

    def assume_dead_after(duration)
      self.assume_max_lifespan = duration
    end

    def logger
      Rails.logger
    end

    def job_class(job)
      job[:method].split('.').first.constantize
    end
  end
  
  attr_reader :opts, :payload
  
  class_attribute :retry_schedule, :method_to_call_after_all_retries_failed, :assume_max_lifespan
  self.retry_schedule = [30.seconds, 2.minutes, 5.minutes]
  self.assume_max_lifespan = 1.hour
  
  def initialize(opts={})
    @opts = opts
  end
  
  def perform
    raise "#{self.class} does not implement the \"perform\" method"
  end
  
  def payload
    opts[:payload]
  end
  
  def logger
    self.class.logger
  end
end
