# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

FeedQueue.create([
  {
    name: :catalog,
    priority: 1,
    batch_size: 100,
    merchant: ENV['MWS_MERCHANT']
  },
  {
    name: :image,
    priority: 1,
    batch_size: 100,
    merchant: ENV['MWS_MERCHANT']
  },
  {
    name: :price,
    priority: 1,
    batch_size: 100,
    merchant: ENV['MWS_MERCHANT']
  },
  {
    name: :shipping,
    priority: 1,
    batch_size: 100,
    merchant: ENV['MWS_MERCHANT']
  },
  {
    name: :inventory,
    priority: 1,
    batch_size: 100,
    merchant: ENV['MWS_MERCHANT']
  }
])