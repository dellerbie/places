$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')
SEEDS_ROOT = File.join(PLACES_ROOT, 'seeds')
RESIZE_IMAGES_ROOT = File.join(PLACES_ROOT, 'resized_images')

require 'places'

# Places::ImagePopulator.populate!
Places::ImageResizer.resize_images