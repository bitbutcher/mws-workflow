class CreateFeedTasks < ActiveRecord::Migration
  def change
    create_table :feed_tasks do |t|
      t.string :sku
      t.integer :queue_id
      t.string :status
      t.datetime :enqueued

      t.timestamps
    end
  end
end
