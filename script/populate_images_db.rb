$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')
SEEDS_ROOT = File.join(PLACES_ROOT, 'seeds')
RESIZE_IMAGES_ROOT = File.join(PLACES_ROOT, 'resized_images')

require 'places'

Places::CategoryBuilder.download_and_save_restaurants_page
# Places::CategoryBuilder.download_and_save_top_40_restaurants_by_category_pages
# 
# Places::BusinessBuilder.businesses_from_category_pages
# Places::BusinessBuilder.download_business_pages
# Places::BusinessBuilder.download_business_image_pages
# 
# Places::ImageBuilder.write_images_to_yaml
# Places::ImageBuilder.download_images_from_yaml

# Places::ImageResizer.resize_images
# Places::ImageResizer.load_images_with_businesses
# Places::ImagePopulator.populate!
