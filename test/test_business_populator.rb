require 'test/unit'
require '../business_populator.rb'

class TestGetBusinessesFromYelp < Test::Unit::TestCase
  def setup
    url = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=african#rpp=40"
    @populator = BusinessPopulator.new(url)
  end
  
  def test_businesses
    businesses = @populator.businesses
    assert(!businesses.empty?)
    b = businesses.first
    assert_equal("Industry Cafe & Jazz", b.name)
    assert_equal("/biz/industry-cafe-and-jazz-culver-city", b.url)
    assert_equal("6039 Washington Blvd", b.street)
    assert_equal("Culver City", b.city)
    assert_equal("(310) 202-6633", b.phone)
  end

end
