require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'places/business'

ENV['http_proxy'] = "http://laocache:8080/"

class BusinessPopulator2
  
  BUSINESS_CATEGORY_URL = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=@@@#rpp=40"
    
    # download businesses_by_category_pages
    # download business_pages
    # download business_images_pages
  
  def self.download_top40_businesses_by_category(category)
    file = File.join('..', 'pages', 'top40', category + '.html')
    unless File.exists?(file)
      url = BUSINESS_CATEGORY_URL.sub(/@@@/, category)
      html = open(url).read
      File.open(file, "w") { |f| f.print html }
    end
  end
  
  def self.download_all_top40_businesses
    categories = YAML::load_file(File.join('..', 'config', 'categories.yml'))
    puts categories
    categories.each do |cat| 
      sleep 1
      download_top40_businesses_by_category(cat)
    end
  end

end
