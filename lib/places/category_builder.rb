require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'

module Places
  class CategoryBuilder
    RESTAURANTS_PAGE = File.join(PLACES_ROOT, 'pages', 'restaurants_index.html')
    CATEGORIES_YAML = File.join(PLACES_ROOT, 'seeds', 'categories.yml')
    BUSINESS_CATEGORY_URL = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=@@@#rpp=40"
    COOKIE = "searchPrefs=%7B%22seen_pop%22%3Afalse%2C%22seen_crop_pop%22%3Afalse%2C%22prevent_scroll%22%3Afalse%2C%22maptastic_mode%22%3Afalse%2C%22mapsize%22%3A%22small%22%2C%22rpp%22%3A40%7D"

    class << self
      def download_and_save_restaurants_page
        return RESTAURANTS_PAGE if File.exists?(RESTAURANTS_PAGE)
        html = open("http://www.yelp.com/c/la/restaurants").read
        File.open(RESTAURANTS_PAGE, 'w') { |page| page.print html }
        RESTAURANTS_PAGE
      end

      def write_categories_to_yaml
        return CATEGORIES_YAML if File.exists?(CATEGORIES_YAML) 
        categories = find_category_nodes_in_restaurants_page
        File.open(CATEGORIES_YAML, 'w') { |out| YAML::dump(categories, out) }
        CATEGORIES_YAML
      end
      
      def find_category_nodes_in_restaurants_page(page = RESTAURANTS_PAGE)
        categories = []
        doc = Nokogiri::HTML(File.read(RESTAURANTS_PAGE))
        doc.css('.browse-by-subject + .browse-by-subject .content li a').each { |node| 
          categories << node['href'].split('/').last.strip
        }
        categories
      end
      
      def download_and_save_top_40_restaurants_by_category_pages
        categories = YAML::load_file(write_categories_to_yaml)
        categories.each do |category|
          file = File.join(PLACES_ROOT, 'pages', 'top40', category + '.html')
          unless File.exists?(file)
            url = BUSINESS_CATEGORY_URL.sub(/@@@/, category)
            puts url
            sleep 1
            html = open(url, "Cookie" => COOKIE).read
            File.open(file, "w") { |f| f.print html }
          end
        end
      end
    end
  end
end