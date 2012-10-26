class FeedTask < ActiveRecord::Base
  attr_accessible :enqueued, :queue_id, :sku, :status

  has_many :feed_task_dependencies, foreign_key: :task_id
  has_many :dependencies, through: :feed_task_dependencies, source: :dependency

  belongs_to :queue, class_name: 'FeedQueue'

  validates_presence_of :queue, :sku
  validates_inclusion_of :status, in: [:enqueued, :in_proccess, :complete]

end
