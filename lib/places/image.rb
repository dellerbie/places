require 'rubygems'
require 'yaml'
require 'fast_stemmer'
require 'active_support/core_ext/string'

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
  
  def resized?
    !(thumb_size.blank?) && !(large_size.blank?)
  end
  
  def to_json
    lg_size = parse_width_and_height(large_size)
    thm_size = parse_width_and_height(thumb_size)
    yelp_id = url.sub(/.*.bphoto./, '').sub(/...jpg/, '')
    {
      :name         => name,
      :description  => description,
      :keywords     => keywords,
      :large_width  => lg_size[0],
      :large_height => lg_size[1],
      :thumb_width  => thm_size[0],
      :thumb_height => thm_size[1],
      :business     => business.to_json,
      :random       => rand
    }
  end
  
  def keywords
    description_no_punc = description.gsub(/[^\s\w]/, '').gsub(/_/, '')
    description_tokens = description_no_punc.split - STOP_WORDS
    words = business.categories + description_tokens
    words.map! { |w| w.downcase.stem }.uniq!
    permutations = words.permutation(2).to_a
    permutations.map! { |perm| perm.join('-') }
    permutations + words
  end
  
  def name
    file_name.sub('.jpg', '')
  end
  
  def parse_width_and_height(dimensions)
    return [0, 0] if dimensions.nil?
    dimensions.split('x').map { |i| i.to_i }
  end
end
