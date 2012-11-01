class CreateBatteries < ActiveRecord::Migration
  def change
    create_table :batteries do | table |
      table.string :device, null: false
      table.integer :capacity, null: false
      table.integer :charge, null: false
      table.timestamps
    end
    add_index(:batteries, :device, unique: true, name: 'uq_battery_device')
  end
end
