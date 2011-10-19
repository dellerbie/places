require 'rubygems'
require 'yaml'
require 'aws-sdk'

module Places
  class SimpleDBImagePopulator
    @sdb = nil
    
    class << self
      def populate
        images = Places::ImageResizer.load_resized_images
        businesses = businesses_to_hash
        load_aws_config
        @sdb = AWS::SimpleDB.new
              
        images.each_with_index do |image, index|
          business = businesses[image.business_url]
          create_item(image, business)
        end
      end
      
      def businesses_to_hash
        businesses = Places::BusinessBuilder.load_businesses
        hash = {}
        businesses.each do |business|
          hash[business.url] = business
        end
        hash
      end
      
      def load_aws_config
        aws_config = File.join(PLACES_ROOT, 'config', 'aws.yml')
        AWS.config(YAML.load_file(aws_config))
      end
      
      def create_item(image, business)
        return unless image.large_size && image.thumb_size
        lg_image_size = image.large_size.split('x')
        sm_image_size = image.thumb_size.split('x')
        
        domain = @sdb.domains.create('prod_places_images')
        item_name = image.file_name.sub('.jpg', '')
        if domain.items[item_name].attributes.collect(&:name).empty?
          domain.items.create(item_name, {
            :description => image.description,
            :large_size_width => lg_image_size[0],
            :large_size_height => lg_image_size[1],
            :thumb_size_width => sm_image_size[0],
            :thumb_size_height => sm_image_size[1],
            :tags => business.categories,
            :business_city => business.city,
            :business_name => business.name,
            :business_phone => business.phone,
            :business_state => business.state,
            :business_zip => business.zip,
            :business_street => business.street
          })
        end
      end
    end
  end
end