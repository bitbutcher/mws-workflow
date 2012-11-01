class CreateFeedTransactions < ActiveRecord::Migration
  def change
    create_table :feed_transactions do | table |
      table.integer :identifier, null: false, limit: 8
      table.string :state, null: false
      table.string :failure, null: true
      table.timestamps
    end
    add_index(:feed_transactions, :identifier, unique: true, name: 'uq_feed_tx_identifier')
    add_index(:feed_transactions, :state, name: 'idx_feed_tx_state')
  end
end
