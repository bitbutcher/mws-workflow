require 'mws'

class FeedQueue < ActiveRecord::Base

  attr_accessible :name, :merchant, :feed_type, :priority, :batch_size

  has_many :tasks, class_name: 'FeedTask', foreign_key: :queue_id

  validates :name, 
    presence: true

  validates :merchant,
    presence: true

  validates :feed_type, 
    presence: true,
    inclusion: { 
      in: Mws::Apis::Feeds::Feed::Type.syms 
    }, 
    uniqueness: { 
      scope: [ :merchant ] 
    }

  validates :priority,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than: 0
    }

  validates :batch_size,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than: 0
    }

  def feed_type
    res = read_attribute(:feed_type)
    res and res.to_sym
  end

end
