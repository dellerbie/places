$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'yaml'
require 'places'

PLACES_ROOT = File.expand_path(File.dirname(__FILE__))
ENV['http_proxy'] = "http://laocache:8080/"

businesses = BusinessPopulator2.create_businesses

