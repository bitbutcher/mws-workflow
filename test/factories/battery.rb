module FactoryGirl

  FactoryGirl.define do

    factory :battery do
      device 'test-device'
      capacity 10
      charge 10
    end

  end

end