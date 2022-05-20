# Require gem uri
require 'uri'
require 'net/http'
require 'nokogiri'
require 'websocket/driver'

uri  = URI("https://opensourcepolitics.eu/references-clients/")
body  = Net::HTTP.get(uri)

document = Nokogiri::HTML(body)
projects = document.css('a')

projects.each do |project|
  next unless project['href'].include?('/project/')
  puts project['href']
end


