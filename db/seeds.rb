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
    task: [ merchant, :SubmitFeed ].join(':'),
    capacity: 10,
    charge: 10
  },
  {
    task: [ merchant, :PollFeeds ].join(':'),
    capacity: 5,
    charge: 5
  },
  {
    task: [ merchant, :GetFeedResult ].join(':'),
    capacity: 10,
    charge: 10
  },
])

FeedTask.transaction do

  product_task = FeedQueue.type(:product).first.enqueue_update(
    Feeds::Product.new('2634897') do
      tax_code 'A_GEN_TAX'
      name "Rocketfish\u2122 6' In-Wall HDMI Cable"
      brand "Rocketfish\u2122"
      description "This 6' HDMI cable supports signals up to 1080p and most screen refresh rates to ensure stunning image clarity with reduced motion blur in fast-action scenes."
      bullet_point 'Compatible with HDMI components'
      bullet_point'Connects an HDMI source to an HDTV or projector with an HDMI input'
      bullet_point 'Up to 15 Gbps bandwidth'
      bullet_point'In-wall rated' 
      msrp 49.99, :usd
      category :ce
      details {
        cable_or_adapter {
          cable_length {
            length 6
            unit_of_measure :feet
          }
        }
      }
    end
  )

  price_task = FeedQueue.type(:price).first.enqueue_update(
    Feeds::PriceListing.new('2634897', 49.99).on_sale(29.99, Time.now, 3.months.from_now),
    product_task
  )

  image_queue = FeedQueue.type(:image).first
  main_image_task = image_queue.enqueue_update(
    Feeds::ImageListing.new('2634897', 'http://images.bestbuy.com/BestBuy_US/images/products/2634/2634897_sa.jpg', 'Main'), 
    product_task
  )
  alt_image_task = image_queue.enqueue_update(
    Feeds::ImageListing.new('2634897', 'http://images.bestbuy.com/BestBuy_US/images/products/2634/2634897cv1a.jpg', 'PT1'), 
    product_task
  )
  
  shipping_task = FeedQueue.type(:override).first.enqueue_update(
    Feeds::Shipping.new('2634897') {
      restricted :alaska_hawaii, :standard, :po_box
      adjust 4.99, :usd, :continental_us, :standard
      replace 11.99, :usd, :continental_us, :expedited, :street
    }, 
    product_task
  )
  
  FeedQueue.type(:inventory).first.enqueue_update(
    Feeds::Inventory.new('2634897', quantity: 10, fulfillment_type: :mfn),
    price_task,
    main_image_task,
    alt_image_task,
    shipping_task
  )
end if FeedTask.all.empty?