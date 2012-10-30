class CreateFeedTransactions < ActiveRecord::Migration
  def change
    create_table :feed_transactions do | table |
      table.integer :identifier, null: false, limit: 8
      table.string :state, null: false
      table.string :failure, null: true
      table.timestamps
    end
  end
end
