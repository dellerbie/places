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
        File.exists?(RESTAURANTS_PAGE) and return
        html = open("http://www.yelp.com/c/la/restaurants").read
        File.open(RESTAURANTS_PAGE, 'w') { |page| page.print html }
        html
      end

      def write_categories_to_yaml
        categories = find_category_nodes_in_restaurants_page
        File.open(CATEGORIES_YAML, 'w') { |out| YAML::dump(categories, out) }
      end
      
      def find_category_nodes_in_restaurants_page(page = RESTAURANTS_PAGE)
        categories = []
        doc = Nokogiri::HTML(File.read(RESTAURANTS_PAGE))
        doc.css('.browse-by-subject + .browse-by-subject .content li a').each { |node| 
          categories << node['href'].split('/').last.strip
        }
        categories
      end
    end
  end
end
