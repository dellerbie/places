class Image
  attr_accessor :url, :description, :business_url, :file_name
  
  def business_folder
    business_url.sub(/\/biz\//, '')
  end
end
