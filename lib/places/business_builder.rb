require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'

module Places
  class BusinessBuilder
    class << self
      def businesses_from_category_pages
        businesses = []
        categories = YAML::load_file(File.join(PLACES_ROOT, 'seeds', 'categories.yml'))
        categories.each { |cat| businesses.concat(businesses_in_category(cat)) }
        save_businesses(businesses)
      end
      
      def businesses_in_category(category)
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
      
      def parse_name(node)
        node.css('h4').text.sub(/\d+\./, '').strip
      end

      def parse_url(node) 
        node.css('h4 a').first['href']
      end

      def parse_address(node)
        address_nodes = node.css('address').children.select { |child| child.text?  }
        city, state_zip = address_nodes[1].text.split(/,/)
        state, zip = state_zip ? state_zip.split : (['', ''])
        { 
          :street =>  address_nodes[0].text.strip,
          :city => city ? city.strip : '',
          :state => state ? state.strip : '',
          :zip => zip ? zip.strip : ''
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
      
      def save_businesses(businesses)
        businesses_file = File.join(PLACES_ROOT, 'seeds', 'businesses.yml')
        File.open(businesses_file, "w") { |out| YAML::dump(businesses.uniq!, out) }
        businesses
      end
    end
  end
end