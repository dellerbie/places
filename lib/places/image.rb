class Image
  attr_accessor :url, :description, :business_url, :file_name, :thumb_size, :large_size, :business
  
  def business_folder
    business_url.sub(/\/biz\//, '')
  end
  
  def thumb_file
    file_name.sub('.jpg', "_sm.jpg")
  end
  
  def large_file
    file_name.sub('.jpg', "_lg.jpg")
  end
end
