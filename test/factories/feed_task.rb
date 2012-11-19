module FactoryGirl

  FactoryGirl.define do
    sequence :index

    factory :feed_task do
      sku '1232323'
      queue FactoryGirl.create(:feed_queue)
      operation_type :update
      body '<Resource/>'

      factory :feed_task_with_failure do
        transaction { FactoryGirl.create(:feed_transaction, state: :has_failures) }
        index
        failure 'Some failure'
      end

      factory :feed_task_with_running_transaction do
        transaction { FactoryGirl.create(:feed_transaction, state: :running) }
        index
      end

      factory :feed_task_with_complete_transaction do
        transaction { FactoryGirl.create(:feed_transaction, state: :complete) }
        index
      end

      factory :feed_task_with_successful_transaction do
        transaction { FactoryGirl.create(:feed_transaction, state: :successful) }
        index
      end

      factory :feed_task_with_failed_transaction do
        transaction { FactoryGirl.create(:feed_transaction, state: :failed) }
        index
      end

    end

  end

end