require 'mws'

class FeedQueue < ActiveRecord::Base

  attr_accessible :priority, :name, :merchant, :batch_size

  has_many :tasks, class_name: 'FeedTask', foreign_key: :queue_id

  validates_presence_of :priority, :name, :merchant
  validates_inclusion_of :name, in: Mws::Apis::Feeds::Feed::Type.syms
  validates_uniqueness_of :name, scope: [ :merchant ]

  def name
    res = read_attribute(:name)
    res and res.to_sym
  end

end
