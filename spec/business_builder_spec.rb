$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'
require 'spec_helper'

describe Places::BusinessBuilder do 
  include Places::SpecHelper
  
  it "should extract businesses from category pages" do 
    businesses = Places::BusinessBuilder.businesses_from_category_pages
    businesses.should_not be_empty
  end
  
  it "should parse a business" do
    business = Places::BusinessBuilder.businesses_from_category_pages.first
    [:name, :url, :city, :state, :zip, :phone, :categories].each do |attribute|
      business.send(attribute).should_not be_empty
    end
  end
  
  it "should save businesses to yaml" do 
    businesses_file = File.join(PLACES_ROOT, 'seeds', 'businesses.yml')
    File.should exist businesses_file
    File.size(businesses_file).should be > 0
  end
  
  it "should not create businesses.yaml if it already exists" do
    overwrites_file?(Places::BusinessBuilder::BUSINESSES_YAML) { 
      Places::BusinessBuilder.businesses_from_category_pages
    }.should_not be_true
  end
  
  it "should download the business pages" do 
    businesses = Places::BusinessBuilder.download_business_pages
    businesses[0..10].each do |biz| 
      page = File.join(PLACES_ROOT, 'pages', 'businesses', biz.page_name)
      File.should exist page
      File.size(page).should be > 0
    end
  end
  
  it "should download the business image pages" do
    businesses = Places::BusinessBuilder.load_businesses
    Places::BusinessBuilder.download_business_image_pages
    
    businesses[0..10].each do |business|
      if(Places::BusinessBuilder.business_images_url(business))
        image_page = File.join(PLACES_ROOT, 'pages', 'images', business.page_name)
        File.should exist image_page
        File.size(image_page).should be > 0
      end
    end
  end
end