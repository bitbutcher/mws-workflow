class CreateFeedQueues < ActiveRecord::Migration
  def change
    create_table :feed_queues do | table |
      table.string :name, null: false
      table.string :feed_type, null: false
      table.integer :priority, null: false
      table.integer :batch_size, null: false
      table.string :merchant, null: false
      table.datetime :last_drain, null: true
      table.timestamps
    end
    add_index(:feed_queues, [ :merchant, :feed_type ], unique: true, name: 'uq_feed_queue_merchant_type')
  end
end
