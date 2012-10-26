class FeedQueue < ActiveRecord::Base
  attr_accessible :name, :priority

  validates_presence_of :name
  validates_uniqueness_of :name
end
