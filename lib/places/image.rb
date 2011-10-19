require 'rubygems'
require 'yaml'
require 'fast_stemmer'

class Image
  attr_accessor :url, :description, :business_url, :file_name, :thumb_size, :large_size, :business
  
  STOP_WORDS = YAML::load_file(File.join(PLACES_ROOT, 'config', 'stopwords.yml'))
  
  def business_folder
    business_url.sub(/\/biz\//, '')
  end
  
  def thumb_file
    file_name.sub('.jpg', "_sm.jpg")
  end
  
  def large_file
    file_name.sub('.jpg', "_lg.jpg")
  end
  
  def to_json
    lg_size = parse_width_and_height(large_size)
    thm_size = parse_width_and_height(thumb_size)
    {
      :name         => name,
      :description  => description,
      :keywords     => keywords,
      :large_width  => lg_size[0],
      :large_height => lg_size[1],
      :thumb_width  => thm_size[0],
      :thumb_height => thm_size[1],
      :business => business.to_json
    }
  end
  
  def keywords
    description_tokens = description.split - STOP_WORDS
    words = business.categories + description_tokens
    words.collect { |w| w.downcase.stem }.uniq!
  end
  
  def name
    file_name.sub('.jpg', '')
  end
  
  def parse_width_and_height(dimensions)
    return [0, 0] if dimensions.nil?
    dimensions.split('x').map { |i| i.to_i }
  end
end
