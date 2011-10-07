require 'rubygems'
require 'nokogiri'
require 'open-uri'

ENV['http_proxy'] = "http://laocache:8080/"

class Business 
  attr_accessor :name, :street, :city, :state, :zip, :url, :phone
end

class BusinessPopulator

  def initialize(url)
    @url = url
    create_parsable_document
  end

  def businesses
    businesses = []
    @doc.css('.businessresult').each { |node| 
      b = Business.new
      b.name = parse_name node
      b.url = parse_url node
      address = parse_address node
      b.street = address[:street]
      b.city = address[:city]
      b.state = address[:state]
      b.zip = address[:zip]
      b.phone = parse_phone node
      businesses << b
    }
    businesses
  end

  private 

  def parse_name(node)
    node.css('h4').text.sub(/\d+\./, '').strip
  end

  def parse_url(node) 
    node.css('h4 a').first['href']
  end

  def parse_address(node)
    address_nodes = node.css('address').children.select { |child| child.text?  }
    p address_nodes[0].text.strip
    city, state_zip = address_nodes[1].text.split(/,/)
    state, zip = state_zip.split
    { 
      :street =>  address_nodes[0].text.strip,
      :city => city.strip,
      :state => state.strip,
      :zip => zip.strip
    }
  end

  def parse_phone(node) 
    node.css('address .phone').text.strip
  end

  def html
    if File.exists?("businesses.html") 
      @html = File.read("businesses.html")
    else
      @html = open(@url).read
      File.open("businesses.html", "w") do |f|
	f.print @html
      end
    end
    @html
  end

  def create_parsable_document
    @doc = Nokogiri::HTML(html)
  end
  
end
