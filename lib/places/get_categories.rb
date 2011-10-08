require 'rubygems'
require 'yaml'
require 'open-uri'
require 'nokogiri'

ENV['http_proxy'] = "http://laocache:8080/"

def categories
  file = File.join('..', '..', 'config', 'categories.yml')
  html = open("http://www.yelp.com/c/la/restaurants").read
  doc = Nokogiri::HTML(html)
  categories = []
  doc.css('.browse-by-subject + .browse-by-subject .content li a').each { |node| 
    puts node['href']
    categories << node['href'].split('/').last.strip
  }
  File.open(file, "w") { |out| YAML::dump(categories, out) }
end

categories
