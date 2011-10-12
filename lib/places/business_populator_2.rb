require 'rubygems'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'digest/sha1'
require 'places/business'
require 'places/image'

class BusinessPopulator2
  
  BUSINESS_CATEGORY_URL = "http://www.yelp.com/search?find_loc=Los+Angeles%2C+CA&cflt=@@@#rpp=40"
  COOKIE = "searchPrefs=%7B%22seen_pop%22%3Afalse%2C%22seen_crop_pop%22%3Afalse%2C%22prevent_scroll%22%3Afalse%2C%22maptastic_mode%22%3Afalse%2C%22mapsize%22%3A%22small%22%2C%22rpp%22%3A40%7D" 
  
  def self.categories
    file = File.join(PLACES_ROOT, 'config', 'categories.yml')
    html = open("http://www.yelp.com/c/la/restaurants").read
    doc = Nokogiri::HTML(html)
    categories = []
    doc.css('.browse-by-subject + .browse-by-subject .content li a').each { |node| 
      puts node['href']
      categories << node['href'].split('/').last.strip
    }
    File.open(file, "w") { |out| YAML::dump(categories, out) }
  end

  def self.top40_by_category(category)
    file = File.join(PLACES_ROOT, 'pages', 'top40', category + '.html')
    unless File.exists?(file)
      url = BUSINESS_CATEGORY_URL.sub(/@@@/, category)
      puts url
      sleep 1
      html = open(url, "Cookie" => COOKIE).read
      File.open(file, "w") { |f| f.print html }
    end
  end
  
  def self.top40
    categories = YAML::load_file(File.join(PLACES_ROOT, 'config', 'categories.yml'))
    categories.each do |cat|
      top40_by_category(cat)
    end
  end

  def self.create_businesses
    puts "Creating businesses from top40 pages..."
    businesses = []
    categories = YAML::load_file(File.join(PLACES_ROOT, 'config', 'categories.yml'))
    categories.each { |cat| businesses.concat(businesses_in_category(cat)) }
    save_businesses(businesses)
  end

  def self.save_businesses(businesses)
    File.open(businesses_file, "w") { |out| YAML::dump(businesses.uniq!, out) }
    puts "Created #{businesses.length} businesses"
    businesses
  end

  def self.businesses_file 
    File.join(PLACES_ROOT, 'config', 'businesses.yml')
  end

  def self.clean_businesses
    load_businesses.uniq!
  end

  def self.load_businesses
    YAML::load_file(businesses_file)
  end

  def self.business_pages
    load_businesses[0..10].each do |biz|
      file = File.join(PLACES_ROOT, 'pages', 'businesses', biz.url.sub(/\/biz\//, '') + '.html')
      unless File.exists?(file)
        sleep 1
        puts "Getting #{biz.url} ..."
        html = open("http://www.yelp.com/#{biz.url}").read
        File.open(file, "w") { |f| f.print html }
      end
    end
  end

  def self.business_image_pages
    load_businesses[0..2].each do |biz|
      biz_page = biz.url.sub(/\/biz\//, '') + '.html'
      file = File.join(PLACES_ROOT, 'pages', 'businesses', biz_page)
      puts "Reading #{biz_page} ..."
      html = open(file).read
      doc = Nokogiri::HTML(html)
      img_anchor = doc.css('#bizPhotos tr td:nth-child(2) a').first
      if(img_anchor)
        href = img_anchor['href'].split('?')[0]
        img_page = open("http://www.yelp.com#{href}").read
        out = File.join(PLACES_ROOT, 'pages', 'images', biz_page)
        File.open(out, 'w') { |f| f.print img_page }
        puts "Wrote #{out}"
      end
    end
  end

  def self.images_to_yaml
    images = []
    load_businesses[0..2].each do |biz|
      biz_img_page = biz.url.sub(/\/biz\//, '') + '.html'
      file = File.join(PLACES_ROOT, 'pages', 'images', biz_img_page)
      puts "Reading #{biz_img_page}..."
      next unless File.exists?(file)
      html = open(file).read
      doc = Nokogiri::HTML(html)
      doc.css('.photos .photo .caption p:nth-child(2)').each do |description_node| 
        image = Image.new
        image.description = description_node.text.strip
#        puts "description => #{image.description}"
        img_node = description_node.parent.parent.css('img').first
#        puts "img_node => #{img_node}"
        image.url = img_node['src'].sub(/\/ms.jpg/, '/l.jpg')
#        puts "url => #{image.url}"
        image.business = biz
        image.tags = image.business.categories
        images << image
      end
      File.open(File.join(PLACES_ROOT, 'config', 'images.yml'), "w") { |out| YAML::dump(images, out) }
      puts "Wrote images.yml"
    end
  end

  def self.image_binaries
    # read images.yml and download all the image urls to ROOT/images
    images = YAML::load_file(File.join(PLACES_ROOT, 'config', 'images.yml'))
    images[0..2].each do |img|
      out = File.join(PLACES_ROOT, 'images', Digest::SHA1.hexdigest(img.description + img.url) + '.jpg')
      open(out, 'wb') do |file|
        file << open(img.url).read
      end
    end
  end
  
  private 
  
  def self.businesses_in_category(category)
    html = File.read(File.join(PLACES_ROOT, 'pages', 'top40', category + '.html'))
    doc = Nokogiri::HTML(html)
    businesses = []
    doc.css('.businessresult').each { |node| 
      b = Business.new
      b.name = parse_name node
      b.url = parse_url node
      address = parse_address node
      b.street = address[:street]
      b.city = address[:city]
      b.state = address[:state]
      b.zip = address[:zip]
      b.phone = parse_phone node
      b.categories = parse_categories node
      businesses << b
    }
    businesses
  end
  
  def self.parse_name(node)
    node.css('h4').text.sub(/\d+\./, '').strip
  end

  def self.parse_url(node) 
    node.css('h4 a').first['href']
  end

  def self.parse_address(node)
    address_nodes = node.css('address').children.select { |child| child.text?  }
    city, state_zip = address_nodes[1].text.split(/,/)
    state, zip = state_zip ? state_zip.split : (['', ''])
    { 
      :street =>  address_nodes[0].text.strip,
      :city => city ? city.strip : '',
      :state => state ? state.strip : '',
      :zip => zip ? zip.strip : ''
    }
  end

  def self.parse_phone(node) 
    node.css('address .phone').text.strip
  end

  def self.parse_categories(node)
    categories = []
    node.css('.itemcategories a').each { |cat| categories << cat.text }
    categories
  end
  
  def pages_root 
    File.join(File.dirname(__FILE__), '..', '..', 'pages')
  end

end
