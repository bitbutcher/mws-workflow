require 'mws'
require 'nokogiri'

class FeedTask < ActiveRecord::Base

  attr_accessible :queue, :sku, :operation_type, :body, :state, :enqueued, :transaction_id

  has_many :feed_task_dependencies, foreign_key: :task_id
  has_many :dependencies, through: :feed_task_dependencies, source: :dependency

  belongs_to :queue, class_name: 'FeedQueue'

  validates :queue,
    presence: true

  validates :sku
    presence: true

  validates :operation_type,
    presence: true,
    inclusion: {
      in: Mws::Apis::Feeds::Feed::OperationType.syms
    }

  validates :state,
    presence: true,
    inclusion: {
      in: [ :pending, :enqueued, :dequeued, :complete, :failed ]
    }

  validates :body,
    presence: true

  def operation_type
    res = read_attribute(:operation_type)
    res and res.to_sym
  end

  def state
    res = read_attribute(:state)
    res and res.to_sym
  end

  def to_xml(name=nil, parent=nil)
    parent << body if parent
    return body
  end

end
