class Business 
  attr_accessor :name, :street, :city, :state, :zip, :url, :phone, :categories
  
    
  def page_name
    url.sub(/\/biz\//, '') + ".html"
  end
end
