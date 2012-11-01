class CreateFeedTaskDependencies < ActiveRecord::Migration
  def up
    create_table :feed_task_dependencies do | table |
      table.integer :task_id, null: false
      table.integer :dependency_id, null: false
      table.timestamps
    end
    add_index(:feed_task_dependencies, [ :task_id, :dependency_id ], unique: true, name: 'uq_feed_task_dep')
    execute <<-SQL
      ALTER TABLE feed_task_dependencies
        ADD CONSTRAINT fk_feed_task_dep_task
        FOREIGN KEY (task_id)
        REFERENCES feed_tasks(id)
    SQL
    execute <<-SQL
      ALTER TABLE feed_task_dependencies
        ADD CONSTRAINT fk_feed_task_dep_dependency
        FOREIGN KEY (dependency_id)
        REFERENCES feed_tasks(id)
    SQL
  end
  def down
    drop_table :feed_task_dependencies
  end
end
