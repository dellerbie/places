$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'

describe Places::Downloaders::Categories do 
  it "should download and save the restaurants index page" do
    Places::Downloaders::Categories.download_and_save_restaurants_page
    File.should exist(Places::Downloaders::Categories::RESTAURANTS_PAGE)
    File.size(Places::Downloaders::Categories::RESTAURANTS_PAGE).should be > 0
  end
  
  it "should not download and save the restaurants index page if it already exists" do
    Places::Downloaders::Categories.download_and_save_restaurants_page
    restaurants_page = Places::Downloaders::Categories::RESTAURANTS_PAGE
    first_time = File.mtime(restaurants_page)
    Places::Downloaders::Categories.download_and_save_restaurants_page
    second_time = File.mtime(restaurants_page)
    first_time.should == second_time
  end

  it "should write categories to yaml" do 
    Places::Downloaders::Categories.download_and_save_restaurants_page
    Places::Downloaders::Categories.write_categories_to_yaml
    File.should exist(Places::Downloaders::Categories::CATEGORIES_YAML)
    File.size(Places::Downloaders::Categories::CATEGORIES_YAML).should be > 0
  end
  
  it "should download and save the top40 restaurants by category pages"
  it "should not download a top40 restaurant category page if it already exists"
end
