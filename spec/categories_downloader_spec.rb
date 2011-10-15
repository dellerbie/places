$:.unshift(File.join('..', 'lib'))

require 'places'
require 'spec_helper'

describe Places::CategoryBuilder do 
  include Places::SpecHelper
  
  it "should download and save the restaurants index page" do
    restaurants_page = Places::CategoryBuilder.download_and_save_restaurants_page
    File.should exist(restaurants_page)
    File.size(restaurants_page).should be > 0
  end
  
  it "should not download and save the restaurants index page if it already exists" do
    overwrites_file?(Places::CategoryBuilder::RESTAURANTS_PAGE) { 
      Places::CategoryBuilder.download_and_save_restaurants_page 
    }.should_not be_true
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
    overwrites_file?((Places::CategoryBuilder::CATEGORIES_YAML)) { 
      Places::CategoryBuilder.write_categories_to_yaml 
    }.should_not be_true
  end
  
  it "should download and save the top40 restaurants by category pages" do
    categories_file = Places::CategoryBuilder.write_categories_to_yaml
    categories = YAML::load_file(categories_file)
    Places::CategoryBuilder.download_and_save_top_40_restaurants_by_category_pages
    categories.each do |category| 
      page = File.join(PLACES_ROOT, 'pages', 'top40', category + '.html')
      File.should exist page
      File.size(page).should be > 0
    end
  end
end
