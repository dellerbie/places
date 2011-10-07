$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'places'

class TestGetBusinessesFromYelp < Test::Unit::TestCase

  def setup
    url = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=african#rpp=40"
    @populator = BusinessPopulator.new(url)
    @business = @populator.businesses.first
  end
  
  def test_businesses
    businesses = @populator.businesses
    assert_equal(8, businesses.length)
  end

  def test_parse_name
    assert_equal("Industry Cafe & Jazz", @business.name)
  end

  def test_parse_street
    assert_equal("6039 Washington Blvd", @business.street)
  end

  def test_parse_url
    assert_equal("/biz/industry-cafe-and-jazz-culver-city", @business.url)
  end

  def test_parse_city
    assert_equal("Culver City", @business.city)
  end

  def test_parse_phone
    assert_equal("(310) 202-6633", @business.phone)
  end

  def test_parse_categories
    assert_equal(["Ethiopian", "Jazz & Blues", "African"], @business.categories)
  end
  
  def test_download_business_pages
    @populator.download_business_pages
    puts File.exists?(File.join(File.dirname(__FILE__), '..', 'pages', "#{@business.url.sub(/\/biz\//, '')}.html"))
    assert(File.exists?(File.join(File.dirname(__FILE__), '..', 'pages', "#{@business.url.sub(/\/biz\//, '')}.html")))
  end

end
