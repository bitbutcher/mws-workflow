require 'mws'

class FeedQueue < ActiveRecord::Base

  attr_accessible :priority, :name, :merchant, :batch_size

  has_many :tasks, class_name: 'FeedTask', foreign_key: :queue_id

  validates :name, 
    presence: true,
    inclusion: { 
      in: Mws::Apis::Feeds::Feed::Type.syms 
    }, 
    uniqueness: { 
      scope: [ :merchant ] 
    }

  validates :merchant,
    presence: true

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

  def name
    res = read_attribute(:name)
    res and res.to_sym
  end

end
