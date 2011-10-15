class Business 
  include Comparable

  attr_accessor :name, :street, :city, :state, :zip, :url, :phone, :categories

  def hash
    url.hash
  end

  def eql?(other)
    self == other
  end

  def ==(other) 
    url == other.url
  end

  def <=>(other)
    url <=> other.url
  end

  def page_name
    "#{url.sub(/\/biz\//, '')}.html"
  end
end
