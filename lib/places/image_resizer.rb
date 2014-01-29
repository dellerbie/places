require 'rubygems'
require 'yaml'
# require 'RMagick'
require 'fileutils'
require 'ruby-progressbar'

module Places
  class ImageResizer
    SMALL_IMAGE_SIZE = '150x150'
    LARGE_IMAGE_SIZE = '612x612'
    RESIZED_IMAGES_YAML = File.join(PLACES_ROOT, 'seeds', 'images_resized.yml')
    IMAGES_BUSINESSES_YAML = File.join(PLACES_ROOT, 'seeds', 'images_with_businesses.yml')
    
    class << self
      def add_businesses_to_images
        images = add_image_dimensions_to_yaml
        FileUtils.cp(RESIZED_IMAGES_YAML, IMAGES_BUSINESSES_YAML)
        businesses = businesses_to_hash
        images.each {|image| image.business = businesses[image.business_url]}
        File.open(IMAGES_BUSINESSES_YAML, "w") { |out| YAML::dump(images, out) }
        images
      end
      
      def load_images_with_businesses
        if File.exists?(IMAGES_BUSINESSES_YAML)
          YAML::load_file(IMAGES_BUSINESSES_YAML)
        else
          add_businesses_to_images
        end
      end
      
      def load_resized_images
        YAML::load_file(RESIZED_IMAGES_YAML)
      end
      
      def businesses_to_hash
        businesses = Places::BusinessBuilder.load_businesses
        hash = {}
        businesses.each do |business|
          hash[business.url] = business
        end
        hash
      end
      
      def add_image_dimensions_to_yaml
        return load_resized_images if File.exists?(RESIZED_IMAGES_YAML)
        images = copy_images_yaml
        progress_bar = ProgressBar.create(:title => "Image Dimensions", :starting_at => 0, :total => images.length)
        images.each do |image|
          progress_bar.increment
          begin
            set_image_dimensions(image)
          rescue Exception => e
            puts e.message
          end
        end
        
        save_images_to_yaml(images)
        images
      end
      
      def set_image_dimensions(image)
        lg_image_path = File.join(RESIZE_IMAGES_ROOT, image.thumb_file)
        sm_image_path = File.join(RESIZE_IMAGES_ROOT, image.large_file)
        return unless File.exists?(lg_image_path) and File.exists?(sm_image_path)
        
        image.thumb_size = image_dimensions(lg_image_path)
        image.large_size = image_dimensions(sm_image_path)
      end
      
      def save_images_to_yaml(images)
        File.open(RESIZED_IMAGES_YAML, "w") { |out| YAML::dump(images, out) }
      end
      
      def image_dimensions(image_path)
        image_binary = Magick::Image.read(image_path).first
        "#{image_binary.columns}x#{image_binary.rows}"
      end
      
      def copy_images_yaml
        FileUtils.cp(Places::ImageBuilder::IMAGES_YAML, RESIZED_IMAGES_YAML)
        load_resized_images
      end
      
      def resize_images
        images = Places::ImageBuilder.load_images
        progress_bar = ProgressBar.create(:title => "Resizing Images", :starting_at => 0, :total => images.length)
        images.each do |img|
          progress_bar.increment
          resize_image(img)
        end
      end
      
      def resize_image(image)
        thumb = File.join(RESIZE_IMAGES_ROOT, image.thumb_file)
        large = File.join(RESIZE_IMAGES_ROOT, image.large_file)
        return if File.exists?(thumb) and File.exists?(large)
        image_path = File.join(SEEDS_ROOT, 'images', image.business_folder, image.file_name)
        resize_image_to_size(image_path, :size => SMALL_IMAGE_SIZE, :extension => :sm)
        resize_image_to_size(image_path, :size => LARGE_IMAGE_SIZE, :extension => :lg)
      end
      
      def resize_image_to_size(image_path, options = {})
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