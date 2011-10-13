$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'

module Places::CategoryBuilderSpecHelper
  def should_not_overwrite(page)
  
  end
end

describe Places::CategoryBuilder do 
  include Places::CategoryBuilderSpecHelper
  
  it "should download and save the restaurants index page" do
    restaurants_page = Places::CategoryBuilder.download_and_save_restaurants_page
    File.should exist(restaurants_page)
    File.size(restaurants_page).should be > 0
  end
  
  it "should not download and save the restaurants index page if it already exists" do
    restaurants_page = Places::CategoryBuilder.download_and_save_restaurants_page
    first_time = File.mtime(restaurants_page)
    sleep 1
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
    categories_yml = Places::CategoryBuilder.write_categories_to_yaml
    File.should exist(categories_yml)
    File.size(categories_yml).should be > 0
  end
  
  it "should not overwrite seeds/categories.yml" do
    Places::CategoryBuilder.download_and_save_restaurants_page
    categories_yaml = Places::CategoryBuilder.write_categories_to_yaml
    first_time = File.mtime(categories_yaml)
    sleep 1  # mtime doesn't track millisecs, so wait a second
    Places::CategoryBuilder.write_categories_to_yaml
    second_time = File.mtime(categories_yaml)
    first_time.should == second_time
  end
  
  it "should download and save the top40 restaurants by category pages" do
    Places::CategoryBuilder.download_and_save_top_40_restaurants_by_category_pages
    
    
  end
  
  #it "should not download a top40 restaurant category page if it already exists"
end
