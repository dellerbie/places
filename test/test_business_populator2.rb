$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'places'

class TestBusinessPopulator < Test::Unit::TestCase

  def test_download_top40_businesses_by_category
    BusinessPopulator2.download_top40_businesses_by_category('african')
    assert(File.exists?(File.join('..', 'pages', 'top40', 'african.html')))
  end

end
