require 'nokogiri'
require 'open-uri'
require_relative 'match'

def extract_data_from_league(url)
  begin
    html = URI.open(url)
    doc = Nokogiri::HTML(html, nil, 'UTF-8')

    match_counter = 0
    matches = []
    teams = []
    results = []

    doc.css('div').each do |con|
      if con['class'] == 'kick__v100-gameCell__team__name'
        teams << con.text
      end
    end

    doc.css('div').each do |con|
      if con['class'] == 'kick__v100-gameList__gameRow'
        match_counter += 1
      end
    end

    doc.css('div').each do |con|
      if con['class'] == 'kick__v100-scoreBoard__scoreHolder '
        con.css('div.kick__v100-scoreBoard__scoreHolder__score').each do |temp|
          results << temp.text.strip
        end
      end
    end

    match_counter.times do |i|
      home = teams[i * 2]
      away = teams[i * 2 + 1]
      matches << Match.new(home, away)
    end

    # transform results into match logic
    formatted_results = []
    if results.length == match_counter * 2
      results.each_slice(2) do |home_score, away_score |
        formatted_results << "#{home_score}:#{away_score}"
      end
    end


    matches.each do |match|
      # here we can identify the result and set it
      match.set_result(formatted_results[matches.index(match)])

      # print results
      puts "#{match.home_team} - #{match.away_team} #{match.result}"
    end
  rescue => exception
    puts "Error: #{exception}"
  end
end

leagues = [
  {:name => "Bundesliga", :url => "https://www.kicker.de/bundesliga/startseite"},
  {:name => "2. Bundesliga", :url => "https://www.kicker.de/2-bundesliga/startseite"},
  {:name => "3. Liga", :url => "https://www.kicker.de/3-liga/startseite"},
  {:name => "Regionalliga", :url => "https://www.kicker.de/regionalliga/startseite"}
]
leagues.each do |league|
  puts "\n"
  puts league[:name] + " from kicker.de: " + league[:url]
  puts "Matches from current matchday:"
  extract_data_from_league(league[:url])
  puts "----------------------------------"
end