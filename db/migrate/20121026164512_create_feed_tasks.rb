class CreateFeedTasks < ActiveRecord::Migration
  def up
    create_table :feed_tasks do | table |
      table.string :sku, null: false
      table.integer :queue_id, null: false
      table.string :operation_type, null: false
      table.text :body, null: false
      table.string :state, null: false, default: :pending
      table.datetime :enqueued, null: true
      table.integer :transaction_id, null: true, :limit => 8
      table.timestamps
    end
    execute <<-SQL
      ALTER TABLE feed_tasks
        ADD CONSTRAINT fk_feed_task_queue
        FOREIGN KEY (queue_id)
        REFERENCES feed_queues(id)
    SQL
  end
  def down
    drop_table :feed_tasks
  end
end
