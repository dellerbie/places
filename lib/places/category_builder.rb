require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'

module Places
  class CategoryBuilder
    RESTAURANTS_PAGE = File.join(PLACES_ROOT, 'pages', 'restaurants_index.html')
    CATEGORIES_YAML = File.join(PLACES_ROOT, 'seeds', 'categories.yml')

    class << self
      def download_and_save_restaurants_page
        File.exists?(RESTAURANTS_PAGE) and return RESTAURANTS_PAGE
        html = open("http://www.yelp.com/c/la/restaurants").read
        File.open(RESTAURANTS_PAGE, 'w') { |page| page.print html }
        RESTAURANTS_PAGE
      end

      def write_categories_to_yaml
        File.exists?(CATEGORIES_YAML) and return CATEGORIES_YAML
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
        
      end
    end
  end
end
