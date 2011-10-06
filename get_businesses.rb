require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'test/unit'

ENV['http_proxy'] = "http://laocache:8080/"

class Business 
  attr_accessor :name, :street, :city, :state, :zip, :url, :phone
end

class BusinessPopulator 

  def initialize(url)
    @url = url
    nokogiri_doc
  end

  def businesses
    businesses = []
    @doc.css('.businessresult').each { |node| 
      b = Business.new
      b.name = node.css('h4').text.sub(/\d+\./, '').strip
      b.url = node.css('h4 a').first['href']
      address = node.css('address').children.select { |child| child.text?  }
      b.street = address[0].text.strip
      b.city, state_zip = address[1].text.split(/,/)
      b.state, b.zip = state_zip.split
      b.phone = node.css('address .phone').text.strip
      businesses << b
    }
    businesses
  end

  private

  def html
    if File.exists?("businesses.html") 
      @html = File.read("businesses.html")
    else
      @html = open(@url).read
      File.open("businesses.html", "w") do |f|
	f.print @html
      end
    end
    @html
  end

  def nokogiri_doc
    @doc = Nokogiri::HTML(html)
  end
  
end

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
