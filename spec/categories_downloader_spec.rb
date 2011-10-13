$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'

describe Places::CategoryBuilder do 
  it "should download and save the restaurants index page" do
    Places::CategoryBuilder.download_and_save_restaurants_page
    File.should exist(Places::CategoryBuilder::RESTAURANTS_PAGE)
    File.size(Places::CategoryBuilder::RESTAURANTS_PAGE).should be > 0
  end
  
  it "should not download and save the restaurants index page if it already exists" do
    Places::CategoryBuilder.download_and_save_restaurants_page
    restaurants_page = Places::CategoryBuilder::RESTAURANTS_PAGE
    first_time = File.mtime(restaurants_page)
    Places::CategoryBuilder.download_and_save_restaurants_page
    second_time = File.mtime(restaurants_page)
    first_time.should == second_time
  end
  
  it "should find category html nodes" do 
    category_nodes = Places::CategoryBuilder.find_category_nodes_in_restaurants_page
    category_nodes.should_not be_empty
    category_nodes.each { |node| node.should_not be_empty }
  end

  it "should write categories to yaml" do 
    Places::CategoryBuilder.download_and_save_restaurants_page
    Places::CategoryBuilder.write_categories_to_yaml
    File.should exist(Places::CategoryBuilder::CATEGORIES_YAML)
    File.size(Places::CategoryBuilder::CATEGORIES_YAML).should be > 0
  end
  
  #it "should download and save the top40 restaurants by category pages"
  #it "should not download a top40 restaurant category page if it already exists"
end
