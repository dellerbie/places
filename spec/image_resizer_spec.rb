$:.unshift(File.join('..', 'lib'))
PLACES_ROOT = File.expand_path('..')
SEEDS_ROOT = File.expand_path('../../places_seeds')
RESIZE_IMAGES_ROOT = File.join(PLACES_ROOT, 'resized_images')

require 'places'
require 'spec_helper'

describe Places::ImageResizer do 
  include Places::SpecHelper
  
  it "should resize image" do
    Places::ImageResizer.resize_images
    
    image = Places::ImageBuilder.load_images.first
    File.should exist(File.join(RESIZE_IMAGES_ROOT, image.thumb_file))
    File.should exist(File.join(RESIZE_IMAGES_ROOT, image.large_file))
  end
end