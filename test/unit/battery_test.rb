require 'test_helper'

class BatteryTest < ActiveSupport::TestCase

  context '.create' do

    should 'be able to create valid battery' do
      battery = create :battery
      assert_not_nil battery
      assert battery.valid?
    end

    should 'require a device' do
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, device: nil
      end
    end    

    should 'require a unique device' do
      create :battery, device: 'test-device'
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, device: 'test-device'
      end
    end  

    should 'require a capacity' do
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, capacity: nil
      end
    end

    should 'require a numeric capacity' do
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, capacity: 'f'
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, capacity: :f
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, capacity: 100.0
      end
      create :battery, capacity: '100'
      create :battery, device: 'second-device', capacity: 100
    end

    should 'require a charge' do
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, charge: nil
      end
    end

    should 'require a numeric charge' do
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, charge: 'f'
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, charge: :f
      end
      assert_raises ActiveRecord::RecordInvalid do
        create :battery, charge: 100.0
      end
      create :battery, charge: '100'
      create :battery, device: 'second-device', charge: 100
    end

  end

  context '#fully_charged?' do

    should 'be fully charged with charge at or above capacity' do
      battery = create :battery, capacity: 10, charge: 10
      assert battery.fully_charged?
    end

    should 'not be fully charged with charge at or above capacity' do
      battery = create :battery, capacity: 10, charge: 8
      assert  !battery.fully_charged?
    end

  end

  context '.discharge' do

    should 'be able to disharge a battery with charge' do
      battery = create :battery, capacity: 10, charge: 10
      assert_not_nil Battery.discharge(battery.device)
      assert_equal 9, Battery.find_by_device(battery.device).charge
    end

    should 'not be able to disharge a batter with no charge' do
      battery = create :battery, capacity: 10, charge: 0
      assert_nil Battery.discharge(battery.device)
    end 

    should 'be able to disharge a batter with a step override' do
      battery = create :battery, capacity: 10, charge: 10
      assert_not_nil Battery.discharge(battery.device, 3)
      assert_equal 7, Battery.find_by_device(battery.device).charge
    end

  end

  context '.charge' do 

    should 'be able to charge a battery' do
      battery = create :battery, capacity: 10, charge: 8
      Battery.charge battery.device
      assert_equal 9, Battery.find_by_device(battery.device).charge
    end

    should 'be able to charge a battery with a step' do
      battery = create :battery, capacity: 10, charge: 7
      Battery.charge battery.device, 3
      assert_equal 10, Battery.find_by_device(battery.device).charge
    end    

    should 'not be able to charge a battery beyond capacity' do
      battery = create :battery, capacity: 10, charge: 10
      Battery.charge battery.device
      assert_equal 10, Battery.find_by_device(battery.device).charge
    end    

  end

end