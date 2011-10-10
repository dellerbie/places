require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'places/business'

# ENV['http_proxy'] = "http://laocache:8080/"

class BusinessPopulator2
  
  BUSINESS_CATEGORY_URL = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=@@@#rpp=40"
  
  # download business_pages
  # download business_images_pages
  
  def self.top40_by_category(category)
    file = File.join(PLACES_ROOT, 'pages', 'top40', category + '.html')
    unless File.exists?(file)
      url = BUSINESS_CATEGORY_URL.sub(/@@@/, category)
      puts url
      sleep 1
      html = open(url).read
      File.open(file, "w") { |f| f.print html }
    end
  end
  
  def self.top40
    categories = YAML::load_file(File.join(PLACES_ROOT, 'config', 'categories.yml'))
    categories.each do |cat|
      top40_by_category(cat)
    end
  end

  def self.businesses
    puts "Getting businesses from Yelp..."
    businesses = []
    categories = YAML::load_file(File.join(PLACES_ROOT, 'config', 'categories.yml'))
    categories.each do |cat|
      businesses << businesses_in_category(cat)
    end
    businesses_file = File.join(PLACES_ROOT, 'config', 'businesses.yml')
    File.open(businesses_file, "w") { |out| YAML::dump(businesses, out) }
    puts "Got #{businesses.length} businesses"
  end
  
  private 
  
  def self.businesses_in_category(category)
    html = File.read(File.join(PLACES_ROOT, 'pages', 'top40', category + '.html'))
    doc = Nokogiri::HTML(html)
    businesses = []
    doc.css('.businessresult').each { |node| 
      b = Business.new
      b.name = parse_name node
      b.url = parse_url node
      address = parse_address node
      b.street = address[:street]
      b.city = address[:city]
      b.state = address[:state]
      b.zip = address[:zip]
      b.phone = parse_phone node
      b.categories = parse_categories node
      businesses << b
    }
    businesses
  end
  
  def self.parse_name(node)
    node.css('h4').text.sub(/\d+\./, '').strip
  end

  def self.parse_url(node) 
    node.css('h4 a').first['href']
  end

  def self.parse_address(node)
    address_nodes = node.css('address').children.select { |child| child.text?  }
    city, state_zip = address_nodes[1].text.split(/,/)
    state, zip = state_zip ? state_zip.split : (['', ''])
    { 
      :street =>  address_nodes[0].text.strip,
      :city => city.strip,
      :state => state.strip,
      :zip => zip.strip
    }
  end

  def self.parse_phone(node) 
    node.css('address .phone').text.strip
  end

  def self.parse_categories(node)
    categories = []
    node.css('.itemcategories a').each { |cat| categories << cat.text }
    categories
  end
  
  def pages_root 
    File.join(File.dirname(__FILE__), '..', '..', 'pages')
  end

end
