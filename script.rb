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
  uri = URI(project['href'])
  body = Net::HTTP.get(uri)
  document = Nokogiri::HTML(body)
  project_name = document.css('h1').text
  open('projects.txt', 'a') do |f|
    f.write project_name + "\n"
  end
end


