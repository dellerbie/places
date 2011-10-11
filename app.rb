$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'yaml'
require 'places'

PLACES_ROOT = File.expand_path(File.dirname(__FILE__))
ENV['http_proxy'] = "http://laocache:8080/"

# BusinessPopulator2.businesses
# businesses = YAML::load_file(File.join(PLACES_ROOT, 'config', 'businesses.yml'))
# puts "There are #{businesses.length} businesses"

BusinessPopulator2.top40
