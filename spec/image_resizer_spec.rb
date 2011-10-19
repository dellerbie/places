$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')
SEEDS_ROOT = File.expand_path('../../places_seeds')
RESIZE_IMAGES_ROOT = File.join(PLACES_ROOT, 'resized_images')

require 'places'
require 'spec_helper'

describe Places::ImageResizer do 
  include Places::SpecHelper
  
  context "resizing images" do 
    it "should resize image" do
      Places::ImageResizer.resize_images
      image = Places::ImageBuilder.load_images.first
      File.should exist(File.join(RESIZE_IMAGES_ROOT, image.thumb_file))
      File.should exist(File.join(RESIZE_IMAGES_ROOT, image.large_file))
    end
  end
  
  context "adding image dimensions to yaml" do
    it "should copy images.yaml" do 
      images = Places::ImageResizer.add_image_dimensions_to_yaml
      copied_image_yaml = Places::ImageResizer::RESIZED_IMAGES_YAML
      File.should exist(copied_image_yaml)
      File.size(copied_image_yaml).should be > 0
      images.first.thumb_size.should_not be_empty
      images.first.large_size.should_not be_empty
    end
    
    it "should add businesses to images yaml" do
      yml_file = Places::ImageResizer::IMAGES_BUSINESSES_YAML
      images = Places::ImageResizer.add_businesses_to_images
      
      File.should exist(yml_file)
      File.size(yml_file).should be > 0
      
      images.first.business.should_not be_nil
      images.first.business.name.should_not be_empty
    end
  end
end