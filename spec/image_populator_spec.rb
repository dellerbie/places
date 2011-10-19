$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')

require 'places'
require 'spec_helper'

describe Places::ImagePopulator do 
  include Places::SpecHelper
  
  it "should get a database object" do
    db = Places::ImagePopulator.db
    db.should_not == nil
  end
  
  it "should populate the database with image documents" do
    db = Places::ImagePopulator.db
    Places::ImagePopulator.populate!
    collection = db[Places::ImagePopulator::IMAGES_COLLECTION]
    collection.count.should be > 0
  end
end