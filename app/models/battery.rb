class Battery < ActiveRecord::Base

  attr_accessible :capacity, :charge, :task

  def fully_charged?
    charge >= capacity
  end

  def self.discharge(task, step=1)
    it = arel_table
    transaction do
      battery = where(it[:task].eq(task).and(it[:charge].gteq(step))).lock(true).first
      unless battery.nil?
        battery.charge -= step
        battery.save!
      end
      battery
    end
  end

  def self.charge(task, step=1)
    update_all(
      ['charge = charge + ?', step], 
      [ 'task = ? and charge < capacity', task ]
    )
  end

end
