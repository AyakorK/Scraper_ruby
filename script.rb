# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'nokogiri'
require 'csv'

# Define the URL to scrape
url = 'http://localhost:3000/processes/curriculum-report/f/3/'

# Initialize a hash to store counts
counts = {
  "En cours de réalisation" => 0,
  "Evaluating" => 0,
  "Autre" => 0
}

# Set the refresh interval in seconds (1 second in this case)
refresh_interval = 0.4

# Main loop
loop do
  uri = URI(url)
  response = Net::HTTP.get(uri)
  document = Nokogiri::HTML(response)

  print "J'enregistre les données dans le fichier CSV\n"
  # Create a CSV file for storing the data
  CSV.open('output.csv', 'w') do |csv|
    # Iterate through the specified div elements
    document.css('div.filters__section.state_check_boxes_tree_filter').each do |filters|
      # Get the text inside the label element
      label_text = filters.css('label').text.strip

      # Check if the label text contains the desired phrases
      if label_text.include?("En cours de réalisation")
        counts["En cours de réalisation"] += 0.5
      elsif label_text.include?("Evaluating")
        counts["Evaluating"] += 0.5
      else
        counts["Autre"] += 0.5
      end
    end
  end

  # Print the counts in the desired format
  counts.each do |label, count|
    puts "#{label} : #{count.ceil}"
  end

  # Sleep for the specified refresh interval before the next iteration
  sleep(refresh_interval)
end
