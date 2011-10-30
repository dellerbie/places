require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'

module Places
  class BusinessBuilder
    BUSINESSES_YAML = File.join(PLACES_ROOT, 'seeds', 'businesses.yml')

    class << self
      def download_business_image_pages
        businesses = load_businesses
        businesses.each do |business|
          image_page = File.join(PLACES_ROOT, 'pages', 'images', business.page_name)
          unless File.exists?(image_page)
            image_anchor = business_images_url(business)
            if(image_anchor)
              sleep rand(3) + 1
              images_page = parse_images_url(image_anchor)
              business.yelp_id = parse_yelp_id_from_url(images_page)
              modified = true
              download_and_save_images_page(images_page, business)
            end
          end
          save_businesses(businesses) if modified
        end
      end
      
      def business_images_url(business)
        file = File.join(PLACES_ROOT, 'pages', 'businesses', business.page_name)
        html = open(file).read
        doc = Nokogiri::HTML(html)
        doc.css('#bizPhotos tr td:nth-child(2) a').first
      end
      
      def parse_yelp_id_from_url(url) 
        url.sub(/\/biz_photos\//, '')
      end
      
      def parse_images_url(node)
        node['href'].split('?')[0]
      end
      
      def download_and_save_images_page(href, business)
        img_page = open("http://www.yelp.com#{href}").read
        puts "Getting image page for #{business.name}"
        out = File.join(PLACES_ROOT, 'pages', 'images', business.page_name)
        File.open(out, 'w') { |f| f.print img_page }
      end
      
      def download_business_pages
        load_businesses.each do |business|
          file = File.join(PLACES_ROOT, 'pages', 'businesses', business.page_name)
          unless File.exists?(file)
            sleep rand(3) + 1
            puts "Getting #{business.url} ..."
            html = open("http://www.yelp.com/#{business.url}").read
            File.open(file, "w") { |f| f.print html }
          end
        end
      end
      
      def load_businesses
        YAML::load_file(BUSINESSES_YAML)
      end
      
      def businesses_from_category_pages
        return load_businesses if File.exists?(BUSINESSES_YAML)
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
        File.open(BUSINESSES_YAML, "w") { |out| YAML::dump(businesses.uniq! || businesses, out) }
        businesses
      end
    end
  end
end