class FeedTaskDependency < ActiveRecord::Base

  attr_accessible :task, :dependency

  belongs_to :task, class_name: 'FeedTask'
  belongs_to :dependency, class_name: 'FeedTask'

  scope :needed_by, ->(task) { where(task_id: task) }
  scope :depend_on, ->(task) { where(dependency_id: task) }

end
