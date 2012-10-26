web: rails s
mws_worker1: env QUEUE="mws" rake jobs:work
mws_worker2: env QUEUE="mws" rake jobs:work
clock: bundle exec clockwork config/clock.rb
