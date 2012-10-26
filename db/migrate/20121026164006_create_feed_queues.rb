class CreateFeedQueues < ActiveRecord::Migration
  def change
    create_table :feed_queues do |t|
      t.string :name
      t.integer :priority

      t.timestamps
    end
  end
end
