$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'yaml'
require 'places'

class TestBusinessPopulator < Test::Unit::TestCase

  def test_download_top40_businesses_by_category
    BusinessPopulator2.download_top40_businesses_by_category('african')
    assert(File.exists?(File.join('..', 'pages', 'top40', 'african.html')))
  end
  
  def test_download_all_top40_businesses
    BusinessPopulator2.download_all_top40_businesses
    categories = Yaml::load(File.join('..', '..', 'config', 'categories.yml'))
    categories.each do |cat| 
      assert(File.exists?(File.join('..', 'pages', 'top40', cat + '.html')))
    end
  end

end
