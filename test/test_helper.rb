ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda'
require 'shoulda-context'
require 'shoulda-matchers'

FactoryGirl.find_definitions

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  include FactoryGirl::Syntax::Methods

  def assert_contains_all(expected, actual)
    tmp = expected.dup
    actual.each do | it |
      assert_contains expected, it
      tmp.delete it
    end
    assert_empty tmp
  end
end


class TestResource

  attr_reader :sku

  def initialize(sku)
    @sku = sku
  end

  def to_xml
    '<Resource/>'
  end

end