$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'

Places::ImagePopulator.populate!