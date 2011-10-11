$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'yaml'
require 'places'

PLACES_ROOT = File.expand_path(File.dirname(__FILE__))
ENV['http_proxy'] = "http://laocache:8080/"

#BusinessPopulator2.images_to_yaml
BusinessPopulator2.image_binaries
