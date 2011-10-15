$:.unshift(File.join('..', 'lib'))

require 'places'
require 'spec_helper'

describe Places::ImageBuilder do 
  include Places::SpecHelper
  
  it "should create images.yml from image pages" do
    images = Places::ImageBuilder.write_images_to_yaml
    images.should_not be_empty
  end
  
  it "should download the image binary" do
    images = Places::ImageBuilder.download_images_from_yaml
    images.should_not be_empty
    images[0..2].each do |image|
      image_binary = File.join(PLACES_ROOT, 'images', image.business_folder, image.file_name)
      File.should exist image_binary
      File.size(image_binary).should be > 0
    end
  end
end