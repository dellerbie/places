require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'digest/sha1'
require 'places/image'
require 'ruby-progressbar'

module Places
  class ImageBuilder
    IMAGES_YAML = File.join(PLACES_ROOT, 'seeds', 'images.yml')
    
    class << self
      def download_images_from_yaml
        images = YAML::load_file(IMAGES_YAML)
        progress_bar = ProgressBar.create(:title => "Downloading Images", :starting_at => 0, :total => images.length)
        images.each do |image|
          progress_bar.increment
          business_image_folder = File.join(PLACES_ROOT, 'images', image.business_folder)
          FileUtils.mkdir(business_image_folder) unless File.exists?(business_image_folder)
          out = File.join(business_image_folder, image.file_name)
          unless File.exists?(out) 
            sleep rand(3) + 1
            open(out, 'wb') { |file| file << open(image.url).read }
          end
        end
      end
      
      def write_images_to_yaml
        return load_images if File.exists?(IMAGES_YAML)
        images = []
        businesses = Places::BusinessBuilder.load_businesses
        progress_bar = ProgressBar.create(:title => "Images.yml", :starting_at => 0, :total => businesses.length)
        businesses.each do |business|
          progress_bar.increment
          img_page = business_image_page(business)
          next unless File.exists?(img_page)
          html = open(img_page).read
          images.concat(parse_business_images_from_page(html, business))
        end
        puts "Saving #{images.length} images to yaml"
        save_images_to_yaml(images)
      end
      
      def load_images
        YAML::load_file(IMAGES_YAML)
      end
      
      def business_image_page(business)
        business_img_page = business.url.sub(/\/biz\//, '') + '.html'
        File.join(PLACES_ROOT, 'pages', 'images', business_img_page)
      end
      
      def parse_business_images_from_page(page, business)
        images = []
        doc = Nokogiri::HTML(page)
        doc.css('.photos-index td.photos .photo .caption p:nth-child(2)').each do |description_node| 
          image = Image.new
          image.description = description_node.text.strip # should get the image description from the img alt attribute, it has more text
          img_node = description_node.parent.parent.css('img').first
          image.url = img_node['src'].sub(/\/ms.jpg/, '/l.jpg')
          image.business_url = business.url
          image.file_name = Digest::SHA1.hexdigest(image.description + image.url) + '.jpg'
          images << image
        end
        images
      end
      
      def save_images_to_yaml(images)
        File.open(IMAGES_YAML, "w") { |out| YAML::dump(images, out) }
        images
      end
    end
  end
end