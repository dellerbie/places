$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'

describe Places::BusinessBuilder do 
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
end