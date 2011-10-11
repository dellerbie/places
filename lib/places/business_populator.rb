require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'places/business'

ENV['http_proxy'] = "http://laocache:8080/"

class BusinessPopulator
  
  BUSINESS_CATEGORY_URL = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=@@@#rpp=40"

  def initialize(url)
    @url = url
    
    # download businesses_by_category_pages
    # download business_pages
    # download business_images_pages    
    
    # get businesses for category
    # download business pages
    # get yelp's business ids
    # get business images using yelps business ids
  end
  
  def self.download_top40_businesses_by_category(category)
    file = File.join('..', 'pages', 'top40', category + '.html')
    if File.exists?(file) 
      html = File.read(file)
    else
      url = BUSINESS_CATEGORY_URL.sub(/@@@/, category)
      html = open(url).read
      File.open(file, "w") { |f| f.print html }
    end
  end

  def businesses
    @businesses = []
    doc = Nokogiri::HTML(html)
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
      @businesses << b
    }
    @businesses
  end
  
  def download_business_pages
    base_url = "http://www.yelp.com"
    @businesses.each { |biz|
      file_name = biz.page_name
      if File.exists?(file_name) 
        #page = File.read(file_name)
      else 
        page = open(base_url + biz.url).read
        File.open(File.expand_path(File.join(pages_root, file_name)), "w") do |f| 
          f.print page
        end
      end
    }
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

  def parse_name(node)
    node.css('h4').text.sub(/\d+\./, '').strip
  end

  def parse_url(node) 
    node.css('h4 a').first['href']
  end

  def parse_address(node)
    address_nodes = node.css('address').children.select { |child| child.text?  }
    city, state_zip = address_nodes[1].text.split(/,/)
    state, zip = state_zip.split
    { 
      :street =>  address_nodes[0].text.strip,
      :city => city.strip,
      :state => state.strip,
      :zip => zip.strip
    }
  end

  def parse_phone(node) 
    node.css('address .phone').text.strip
  end

  def parse_categories(node)
    categories = []
    node.css('.itemcategories a').each { |cat| categories << cat.text }
    categories
  end
  
  def pages_root 
    File.join(File.dirname(__FILE__), '..', '..', 'pages')
  end

end
