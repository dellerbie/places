require 'rubygems'
require 'yaml'
require 'json'
require 'mongo'

module Places
  class ImagePopulator
    @db = nil
    IMAGES_COLLECTION = 'images'
    
    class << self
      def populate!
        images = load_images_from_yaml
        _collection = collection
        _collection.drop();
        
        images.each do |image|
          next if not image.resized?
          _collection.insert(image.to_json)
        end
        _collection.create_index('keywords')
        _collection.create_index('business.nomalized_name')
        _collection.create_index('random')
      end
      
      def load_images_from_yaml
        Places::ImageResizer.load_images_with_businesses
      end
      
      def db
        @db ||= Mongo::Connection.new.db('places_development')
      end
      
      def collection
        _db = db
        _db[Places::ImagePopulator::IMAGES_COLLECTION]
      end
    end
  end
end