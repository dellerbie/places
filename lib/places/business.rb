class Business 

  attr_accessor :name, :street, :city, :state, :zip, :url, :phone, :categories, :yelp_id

  def hash
    url.hash
  end

  def eql?(other)
    self == other
  end

  def ==(other) 
    url == other.url
  end

  def page_name
    "#{url.sub(/\/biz\//, '')}.html"
  end
  
  def to_json
    {
      :name           => name,
      :nomalized_name => url.sub(/\/biz\//, ''),
      :yelp_id        => yelp_id,
      :street         => street,
      :city           => city,
      :state          => state,
      :zip            => zip.to_i,
      :phone          => phone,
      :categories     => categories
    }
  end
end
