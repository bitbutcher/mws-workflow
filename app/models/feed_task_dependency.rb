class FeedTaskDependency < ActiveRecord::Base
  belongs_to :task, class_name: 'FeedTask'
  belongs_to :dependency, class_name: 'FeedTask'
end
