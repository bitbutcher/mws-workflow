module FactoryGirl

  FactoryGirl.define do

    factory :feed_queue do
      name :product
      feed_type :product
      merchant '123123213'
      priority 1
      batch_size 100

      factory :product_queue do 
        feed_type :product
      end

      factory :image_queue do 
        feed_type :image
      end

      factory :price_queue do 
        feed_type :price
      end

      factory :inventory_queue do 
        feed_type :inventory
      end

      factory :override_queue do
        feed_type :override
      end

    end

  end

end