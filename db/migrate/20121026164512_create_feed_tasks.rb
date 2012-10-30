class CreateFeedTasks < ActiveRecord::Migration
  def up
    create_table :feed_tasks do | table |
      table.string :sku, null: false
      table.integer :queue_id, null: false
      table.string :operation_type, null: false
      table.text :body, null: false
      table.integer :transaction_id, null: true
      table.integer :index, null: true
      table.text :failure, null: true
      table.timestamps
    end
    execute <<-SQL
      ALTER TABLE feed_tasks
        ADD CONSTRAINT fk_feed_task_queue
        FOREIGN KEY (queue_id)
        REFERENCES feed_queues(id)
    SQL
    execute <<-SQL
      ALTER TABLE feed_tasks
        ADD CONSTRAINT fk_feed_task_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES feed_transactions(id)
    SQL
  end
  def down
    drop_table :feed_tasks
  end
end
