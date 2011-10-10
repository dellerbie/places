$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'yaml'
require 'places'

PLACES_ROOT = File.expand_path(File.join('..', File.dirname(__FILE__)))

class TestBusinessPopulator < Test::Unit::TestCase

  def test_top40_by_category
    BusinessPopulator2.top40_by_category('african')
    assert(File.exists?(File.join(PLACES_ROOT, 'pages', 'top40', 'african.html')))
  end
  
  def test_top40
    BusinessPopulator2.top40
    categories = YAML::load_file(File.join(PLACES_ROOT, 'config', 'categories.yml'))
    categories.each do |cat| 
      assert(File.exists?(File.join(PLACES_ROOT, 'pages', 'top40', cat + '.html')))
    end
  end
  
  def test_businesses_in_category
    BusinessPopulator2.businesses_in_category('african')
    businesses = YAML::load_file(File.join(PLACES_ROOT, 'config', 'businesses.yml'))
    assert(businesses.any? { |b| b.categories.include?('African') })
  end
end
