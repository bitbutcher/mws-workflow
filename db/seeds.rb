require 'mws'

Feeds = Mws::Apis::Feeds
Feed = Feeds::Feed

FeedQueue.create!([
  {
    name: 'Catalog',
    merchant: ENV['MWS_MERCHANT'],
    feed_type: Feed::Type.PRODUCT.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Images',
    merchant: ENV['MWS_MERCHANT'],
    feed_type: Feed::Type.IMAGE.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Pricing',
    merchant: ENV['MWS_MERCHANT'],
    feed_type: Feed::Type.PRICE.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Shipping',
    merchant: ENV['MWS_MERCHANT'],
    feed_type: Feed::Type.OVERRIDE.sym,
    priority: 1,
    batch_size: 100
  },
  {
    name: 'Inventory',
    merchant: ENV['MWS_MERCHANT'],
    feed_type: Feed::Type.INVENTORY.sym,
    priority: 1,
    batch_size: 100
  }
])

FeedTask.transaction do

  product_queue = FeedQueue.where(feed_type: :product).first
  product = Feeds::Product.new('2634897') do
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
  product_task = FeedTask.create sku: '2634897', queue: product_queue, operation_type: :update, body: product.to_xml.to_s

  price_queue = FeedQueue.where(feed_type: :price).first
  price = Feeds::PriceListing.new('2634897', 49.99).on_sale(29.99, Time.now, 3.months.from_now)
  price_task = FeedTask.create sku: '2634897', queue: price_queue, operation_type: :update, body: price.to_xml.to_s
  price_task.dependencies << product_task

  image_queue = FeedQueue.where(feed_type: :image).first
  main_image = Feeds::ImageListing.new('2634897', 'http://images.bestbuy.com/BestBuy_US/images/products/2634/2634897_sa.jpg', 'Main')
  main_image_task = FeedTask.create sku: '2634897', queue: image_queue, operation_type: :update, body: main_image.to_xml.to_s
  main_image_task.dependencies << product_task
  alt_image = Feeds::ImageListing.new('2634897', 'http://images.bestbuy.com/BestBuy_US/images/products/2634/2634897cv1a.jpg', 'PT1')
  alt_image_task = FeedTask.create sku: '2634897', queue: image_queue, operation_type: :update, body: alt_image.to_xml.to_s
  alt_image_task.dependencies << product_task

  shipping_queue = FeedQueue.where(feed_type: :price).first
  shipping = Feeds::Shipping.new('2634897') {
    restricted :alaska_hawaii, :standard, :po_box
    adjust 4.99, :usd, :continental_us, :standard
    replace 11.99, :usd, :continental_us, :expedited, :street
  }
  shipping_task = FeedTask.create sku: '2634897', queue: shipping_queue, operation_type: :update, body: shipping.to_xml.to_s
  shipping_task.dependencies << product_task

  inventory_queue = FeedQueue.where(feed_type: :inventory).first
  inventory = Feeds::Inventory.new('2634897', quantity: 10, fulfillment_type: :mfn)
  inventory_task = FeedTask.create sku: '2634897', queue: inventory_queue, operation_type: :update, body: inventory.to_xml.to_s
  inventory_task.dependencies << price_task
  inventory_task.dependencies << main_image_task
  inventory_task.dependencies << alt_image_task
  inventory_task.dependencies << shipping_task

end if FeedTask.all.empty?