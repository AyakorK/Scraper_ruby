# frozen_string_literal: true

# Require gem uri
require 'uri'
require 'net/http'
require 'nokogiri'
require 'csv'

def find_unique_link(links, variable, unique_link)
  links.each do |link|
    href =  link['href'].to_s

    next if check_if_valid(href, variable)
    next if variable == 4 && href.downcase.include?('opensource') || !href.start_with?('https')

    unless unique_link.include?(link['href']) || unique_link.include?(link['href'].chomp('/'))
      (unique_link[variable] = link['href']) and break
    end
  end
end

def check_if_valid(href, variable)
  (href.downcase.include?('open') && variable != 4) || !(href.end_with?('.fr') ||
    href.end_with?('.is') || href.end_with?('.be') ||
    href.end_with?('.brussels') || href.end_with?('.paris') ||
    (href.count('/') == 3 && href.gsub(/[[:space:]]/, '').end_with?('/') ||
      href.downcase.include?('participez') || href.downcase.include?('democratie'))) ||
    !href.start_with?('https')
end

def get_all_links_from(document)
  document.css('a')
end

def is_client_page?(html_link)
  html_link.text == 'Clients'
end

uri = URI('https://opensourcepolitics.eu')
body = Net::HTTP.get(uri)
# Navigate to "https://opensourcepolitics.eu/references-clients/" by clicking on the "Client" button
document = Nokogiri::HTML(body)
data = []
index = 1


get_all_links_from(document).each do |html_link|
  next unless is_client_page?(html_link)

  client_link = html_link['href']

  uri = URI(client_link)
  body = Net::HTTP.get(uri)
  document_body = Nokogiri::HTML(body)
  projects = get_all_links_from(document_body)
  unique_links = {}

  projects.each do |project|
    next unless project['href'].to_s.include?('/project/')

    uri = URI(project['href'])
    body = Net::HTTP.get(uri)
    project_document_body = Nokogiri::HTML(body)
    links = get_all_links_from(project_document_body)

    project_name = project_document_body.css('h1').text.gsub(/[[:space:]]/, ' ')

    image = project.css('img').attribute('data-lazy-srcset').value.split(' ')[0]

    find_unique_link(links, index, unique_links)

    puts "#{unique_links.length} / #{index}"

    data << [project_name, image, unique_links[index]].join(',')

    index += 1
  end
end

CSV.open('output/projects.csv', 'w') do |csv|
  csv << ['Project Name', 'Image', 'Link']
  data.each do |row|
    csv << row.split(',').map(&:strip)
  end
end
