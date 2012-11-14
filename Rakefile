#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'queue_classic'
require 'queue_classic/tasks'

MwsWorkflow::Application.load_tasks

namespace :mws do
  
  task :load, [ :file ] => :environment do | t, args |

    mapper = Mapping::Mapper.new
    mapper << {
      category: :ce,
      selector: ->(product) {
        not product['details'].empty? and product['class'] == 'AUDIO &#38; VIDEO CABLES'
      },
      rules: -> {
        cable_or_adapter.cable_length { as_distance details.name('Length of Cord') }
      }
    }
    mapper << {
      category: :wireless,
      selector: ->(product) {
        not product['details'].empty? and product['class'] == 'MOBILE PHONE ACCY'
      },
      rules: -> {
        wireless_accessories!.compatible_phone_models { details.name('What model phone does this fit') }
      }
    }

    open_api = BbyOpen::Api.new ENV['BBY_OPEN_KEY']
    File.open(args[:file]) do | file |
      file.each do | line | 
        bby_open_product = open_api.get_sku(line.chomp)
        prod_category, prod_details = mapper.map bby_open_product
        unless prod_details.nil?
          sku = bby_open_product['sku']
          FeedTask.transaction do
            product_task = FeedQueue.type(:product).first.enqueue_update(
              Mws::Product(sku) do
                upc bby_open_product['upc']
                name bby_open_product['name']
                brand bby_open_product['manufacturer']
                manufacturer bby_open_product['manufacturer']
                tax_code 'A_GEN_TAX'
                description bby_open_product['longDescription']
                shipping_weight bby_open_product['shippingWeight'] 
                bby_open_product['features'].each { | feature | bullet_point feature['feature'] }
                category prod_category
                details prod_details
              end  
            )
            inventory_deps = []
            inventory_deps << FeedQueue.type(:price).first.enqueue_update(
              Mws::PriceListing(sku, bby_open_product['regularPrice']),
              product_task
            )
            
            image_queue = FeedQueue.type(:image).first
            inventory_deps << image_queue.enqueue_update(
              Mws::ImageListing(sku, bby_open_product['largeImage'], 'Main'), 
              product_task
            ) unless bby_open_product['largeImage'].nil?
            inventory_deps << image_queue.enqueue_update(
              Mws::ImageListing(sku, bby_open_product['alternateViewsImage'], 'PT1'), 
              product_task
            ) unless bby_open_product['alternateViewsImage'].nil?
            
            shipping = bby_open_product['shipping']
            unless shipping.nil? or shipping.empty?
              shipping = shipping.first
              inventory_deps << FeedQueue.type(:override).first.enqueue_update(
                Mws::Shipping(sku) {
                  replace shipping['ground'], :usd, :continental_us, :standard, :street if shipping['ground']
                  replace shipping['secondDay'], :usd, :continental_us, :two_day, :street if shipping['secondDay']
                  replace shipping['nextDay'], :usd, :continental_us, :one_day, :street if shipping['nextDay']
                }, 
                product_task
              )
            end
            FeedQueue.type(:inventory).first.enqueue_update(
              Mws::Inventory(sku, quantity: 10, fulfillment_type: :mfn), *inventory_deps
            )
          end
        end
      end
    end
  end
end

