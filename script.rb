# frozen_string_literal: true

# Require gem uri
require 'uri'
require 'net/http'
require 'nokogiri'
require 'websocket/driver'
require 'csv'

uri = URI('https://opensourcepolitics.eu')
body = Net::HTTP.get(uri)
# Navigate to "https://opensourcepolitics.eu/references-clients/" by clicking on the "Client" button
doc = Nokogiri::HTML(body)
data = []
doc.css('a').each do |first_link|
  next unless first_link.text == 'Clients'

  client_link = first_link['href']
  i = 1

  uri = URI(client_link)
  body = Net::HTTP.get(uri)
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
      href =  link['href'].to_s
      next if (href.downcase.include?('open') && i != 4) || !(href.end_with?('.fr') ||
        href.end_with?('.is') || href.end_with?('.be') ||
        href.end_with?('.brussels') || href.end_with?('.paris') ||
        (href.count('/') == 3 && href.gsub(/[[:space:]]/, '').end_with?('/') ||
          href.downcase.include?('participez') || href.downcase.include?('democratie'))) ||
              !href.start_with?('https')
      next if i == 4 && href.downcase.include?('opensource') || !href.start_with?('https')
      unless unique_link.include?(link['href']) || unique_link.include?(link['href'].chomp('/'))
        (unique_link[i] =
           link['href']) and break
      end
    end
    puts "#{unique_link.length} / #{i}"
    data << [project_name, image, unique_link[i]].join(',')
    i += 1
  end
end

CSV.open('projects.csv', 'w') do |csv|
  csv << ['Project Name', 'Image', 'Link']
  data.each do |row|
    csv << row.split(',').map(&:strip)
  end
end