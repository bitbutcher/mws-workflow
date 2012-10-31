class CreateBatteries < ActiveRecord::Migration
  def change
    create_table :batteries do | table |
      table.string :task, null: false
      table.integer :capacity, null: false
      table.integer :charge, null: false
      table.timestamps
    end
  end
end
