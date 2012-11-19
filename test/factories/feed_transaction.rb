module FactoryGirl

  FactoryGirl.define do
    sequence :identifier

    factory :feed_transaction do
      identifier
      state :running
    end

  end

end