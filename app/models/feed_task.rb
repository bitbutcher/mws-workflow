require 'mws'
require 'nokogiri'

class FeedTask < ActiveRecord::Base

  attr_accessible :queue, :sku, :operation_type, :body, :transaction, :index, :failure

  has_many :feed_task_dependencies, foreign_key: :task_id
  has_many :dependencies, through: :feed_task_dependencies, source: :dependency

  belongs_to :queue, class_name: 'FeedQueue'
  belongs_to :transaction, class_name: 'FeedTransaction'

  validates :queue,
    presence: true

  validates :sku,
    presence: true

  validates :operation_type,
    presence: true,
    inclusion: {
      in: Mws::Apis::Feeds::Feed::OperationType.syms
    }

  validates :body,
    presence: true

  validates :index,
    numericality: {
      integer_only: true,
      greater_than: 0
    },
    uniqueness: { 
      scope: [ :transaction_id ] 
    },
    allow_blank: true

  scope :pending, -> {
    task = arel_table
    where(transaction_id: nil).where FeedTaskDependency.needed_by(task[:id]).exists
  }

  scope :ready, -> {
    task = arel_table
    where(transaction_id: nil).where FeedTaskDependency.needed_by(task[:id]).exists.not
  }

  scope :running, -> {
    tx = FeedTransaction.arel_table
    joins(:transaction).where tx[:state].eq(:running)
  }

  scope :complete, -> {
    tx = FeedTransaction.arel_table
    joins(:transaction).where tx[:state].eq(:complete)
  }

  scope :failed, -> {
    task = arel_table
    where task[:failure].not_eq(nil)
  }

  def operation_type
    res = read_attribute(:operation_type)
    res and res.to_sym
  end

  def to_xml(name=nil, parent=nil)
    parent << body if parent
    return body
  end

end
