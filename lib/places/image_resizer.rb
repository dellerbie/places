require 'rubygems'
require 'yaml'
require 'aws-sdk'
require 'RMagick'

module Places
  class ImageResizer
    SMALL_IMAGE_SIZE = '100x100'
    LARGE_IMAGE_SIZE = '240x240'  
    
    class << self  
      def resize_images
        images = Places::ImageBuilder.load_images
        images.each {|img| resize_image(img) }
      end
      
      def resize_image(image)
        thumb = File.join(RESIZE_IMAGES_ROOT, image.thumb_file)
        large = File.join(RESIZE_IMAGES_ROOT, image.large_file)
        return if File.exists?(thumb) and File.exists?(large)
        image_path = File.join(SEEDS_ROOT, 'images', image.business_folder, image.file_name)
        resize_image_to_size(image_path, :size => SMALL_IMAGE_SIZE, :extension => :sm)
        resize_image_to_size(image_path)
      end
      
      def resize_image_to_size(image_path, options = {:size => LARGE_IMAGE_SIZE, :extension => :lg})
        return unless File.exists?(image_path)
        begin 
          img = Magick::Image.read(image_path).first
          image_name = File.basename(image_path);
          thumb = img.change_geometry(options[:size]) do |cols, rows, i| 
            i.resize!(cols, rows)
          end
          thumb.write(File.join(RESIZE_IMAGES_ROOT, image_name.sub('.jpg', "_#{options[:extension].to_s}.jpg")))
        rescue Exception => e
          puts e.message
        end
      end
    end
  end
end