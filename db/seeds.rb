require 'mws'

Feeds = Mws::Apis::Feeds
Feed = Feeds::Feed

merchant = ENV['MWS_MERCHANT']

FeedQueue.create!([
  {
    name: 'Catalog',
    merchant: merchant,
    feed_type: Feed::Type.PRODUCT.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Images',
    merchant: merchant,
    feed_type: Feed::Type.IMAGE.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Pricing',
    merchant: merchant,
    feed_type: Feed::Type.PRICE.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Shipping',
    merchant: merchant,
    feed_type: Feed::Type.OVERRIDE.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Inventory',
    merchant: merchant,
    feed_type: Feed::Type.INVENTORY.sym,
    priority: 1,
    batch_size: 100
  }
])

Battery.create!([
  {
    device: [ :SubmitFeed, merchant ].join(':'),
    capacity: 10,
    charge: 10
  },
  {
    device: [ :PollFeeds, merchant ].join(':'),
    capacity: 5,
    charge: 5
  },
  {
    device: [ :GetFeedResult, merchant ].join(':'),
    capacity: 10,
    charge: 10
  },
])
