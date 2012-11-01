#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'queue_classic'
require 'queue_classic/tasks'

MwsWorkflow::Application.load_tasks

namespace :mws do
  desc "Loads some skus into FeedTasks and FeedQueues"
  task workflow: :environment do
    Feeds = Mws::Apis::Feeds
    FeedTask.transaction do
      product_task = FeedQueue.type(:product).first.enqueue_update(
        Feeds::Product.new('2634897') do
          upc '600603133978'
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
      product_task = FeedQueue.type(:product).first.enqueue_update(
        Feeds::Product.new('3455449') do
          upc '600603143892'
          tax_code 'A_GEN_TAX'
          name "Rocketfish\u2122 5' In-Wall HDMI Cable"
          brand "Rocketfish\u2122"
          description "This 5' HDMI cable supports signals up to 1080p and most screen refresh rates to ensure stunning image clarity with reduced motion blur in fast-action scenes."
          bullet_point 'Compatible with HDMI components'
          bullet_point'Connects an HDMI source to an HDTV or projector with an HDMI input'
          bullet_point 'Up to 15 Gbps bandwidth'
          bullet_point'In-wall rated' 
          msrp 29.99, :usd
          category :ce
          details {
            cable_or_adapter {          
              cable_length {
                length 5
                unit_of_measure :feet
              }
            }
          }
        end
      )
      price_task = FeedQueue.type(:price).first.enqueue_update(
        Feeds::PriceListing.new('3455449', 29.99).on_sale(19.99, Time.now, 3.months.from_now),
        product_task
      )
      image_queue = FeedQueue.type(:image).first
      main_image_task = image_queue.enqueue_update(
        Feeds::ImageListing.new('3455449', 'http://images.bestbuy.com/BestBuy_US/images/products/3455/3455449_sa.jpg', 'Main'), 
        product_task
      )
      alt_image_task = image_queue.enqueue_update(
        Feeds::ImageListing.new('3455449', 'http://images.bestbuy.com/BestBuy_US/images/products/3455/3455449cv1a.jpg', 'PT1'), 
        product_task
      )
      shipping_task = FeedQueue.type(:override).first.enqueue_update(
        Feeds::Shipping.new('3455449') {
          restricted :alaska_hawaii, :standard, :po_box
          adjust 4.99, :usd, :continental_us, :standard
          replace 11.99, :usd, :continental_us, :expedited, :street
        }, 
        product_task
      )
      FeedQueue.type(:inventory).first.enqueue_update(
        Feeds::Inventory.new('3455449', quantity: 5, fulfillment_type: :mfn),
        price_task,
        main_image_task,
        alt_image_task,
        shipping_task
      )
      product_task = FeedQueue.type(:product).first.enqueue_update(
        Feeds::Product.new('8744969') do
          upc '600603117169'
          tax_code 'A_GEN_TAX'
          name "Dynex\u2122 6' 6-Outlet Surge Protector"
          brand "Dynex\u2122"
          description "This 6' HDMI cable supports signals up to 1080p and most screen refresh rates to ensure stunning image clarity with reduced motion blur in fast-action scenes."
          bullet_point '6 surge-protected outlets'
          bullet_point '900-joule rating'
          bullet_point 'electronics and computer equipment protection'
          msrp 12.99, :usd
          category :ce
          details {
            power_supplies_or_protection {          
            }
          }
        end
      )
      price_task = FeedQueue.type(:price).first.enqueue_update(
        Feeds::PriceListing.new('8744969', 12.99),
        product_task
      )
      image_queue = FeedQueue.type(:image).first
      main_image_task = image_queue.enqueue_update(
        Feeds::ImageListing.new('8744969', 'http://images.bestbuy.com/BestBuy_US/images/products/8744/8744969_ra.jpg', 'Main'), 
        product_task
      )
      shipping_task = FeedQueue.type(:override).first.enqueue_update(
        Feeds::Shipping.new('8744969') {
          restricted :alaska_hawaii, :standard, :po_box
          adjust 7.99, :usd, :continental_us, :standard
          replace 14.99, :usd, :continental_us, :expedited, :street
        }, 
        product_task
      )
      FeedQueue.type(:inventory).first.enqueue_update(
        Feeds::Inventory.new('8744969', quantity: 15, fulfillment_type: :mfn),
        price_task,
        main_image_task,
        alt_image_task,
        shipping_task
      )
    end
  end

end

