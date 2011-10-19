$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')
SEEDS_ROOT = File.expand_path('../../places_seeds')

require 'places'
require 'spec_helper'
require 'aws-sdk'

describe Places::SimpleDBImagePopulator do 
  include Places::SpecHelper
  
  # it "should populate the simple db" do
  #   Places::SimpleDBImagePopulator.populate
  # 
  #   sdb = AWS::SimpleDB.new
  #   domain = sdb.domains.create('prod_places_images')
  #   domain.items.count.should be > 0
  #   
  #   item = domain.items.first
  #   item.name.should_not be_empty
  #   attributes = [:description, :large_size_width, :large_size_height, 
  #     :thumb_size_width, :thumb_size_height, :tags, :business_city,
  #     :business_name, :business_phone, :business_state, :business_zip,
  #     :business_street]
  #   attributes.each do |attr|
  #     item.attributes[attr].name.should_not be_empty
  #   end
  # end
end