# frozen_string_literal: true

# Require gem uri
require 'uri'
require 'net/http'
require 'nokogiri'
require 'websocket/driver'
require 'csv'

uri = URI('https://opensourcepolitics.eu/references-clients/')
body = Net::HTTP.get(uri)

i = 1

document = Nokogiri::HTML(body)
projects = document.css('a')
unique_link = {}

projects.each do |project|
  next unless project['href'].to_s.include?('/project/')

  uri = URI(project['href'])
  body = Net::HTTP.get(uri)
  project_document = Nokogiri::HTML(body)
  links = project_document.css('a')
  project_name = project_document.css('h1').text.gsub(/[[:space:]]/, ' ')
  image = project.css('img').attribute('data-lazy-srcset').value.split(' ')[0]
  links.each do |link|
    next if (link['href'].to_s.downcase.include?('open') && i != 4) || !(link['href'].to_s.end_with?('.fr') || link['href'].to_s.end_with?('.is') || link['href'].to_s.end_with?('.be') || link['href'].to_s.end_with?('.brussels') || link['href'].to_s.end_with?('.paris') || (link['href'].to_s.count('/') == 3 && link['href'].to_s.gsub(
      /[[:space:]]/, ''
    ).end_with?('/') || link['href'].to_s.downcase.include?('participez') || link['href'].to_s.downcase.include?('democratie'))) || !link['href'].to_s.start_with?('https')
    next if i == 4 && link['href'].to_s.downcase.include?('opensource') || !link['href'].to_s.start_with?('https')
    # puts "#{link['href']}"
    unless unique_link.include?(link['href']) || unique_link.include?(link['href'].chomp('/'))
      (unique_link[i] =
         link['href']) and break
    end
  end
  puts "#{unique_link.length} / #{i}"
  data = [i, project_name, image, unique_link[i]]
  CSV.open('projects.csv', 'a') do |csv|
    csv << data
  end
  i += 1
end
