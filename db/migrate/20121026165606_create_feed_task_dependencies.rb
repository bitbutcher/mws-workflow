class CreateFeedTaskDependencies < ActiveRecord::Migration
  def change
    create_table :feed_task_dependencies do |t|
      t.integer :task_id
      t.integer :dependency_id

      t.timestamps
    end
  end
end
