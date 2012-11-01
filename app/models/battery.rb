class Battery < ActiveRecord::Base

  attr_accessible :device, :capacity, :charge

  def fully_charged?
    charge >= capacity
  end

  def self.discharge(device, step=1)
    it = arel_table
    transaction do
      battery = where(it[:device].eq(device).and(it[:charge].gteq(step))).lock(true).first
      unless battery.nil?
        battery.charge -= step
        battery.save!
      end
      battery
    end
  end

  def self.charge(device, step=1)
    update_all(
      ['charge = charge + ?', step], 
      [ 'device = ? and charge < capacity', device ]
    )
  end

end
