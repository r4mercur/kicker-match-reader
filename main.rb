require 'nokogiri'
require 'open-uri'
require 'mongo'
require_relative 'match'

Mongo::Logger.logger.level = ::Logger::FATAL
client = Mongo::Client.new("mongodb://admin:Lw4EGf67a6WJ@localhost:27017")
db = client.use('football')
$collection = db[:matches]

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
    results.each_slice(2) do |home_score, away_score |
      formatted_results << "#{home_score}:#{away_score}"
    end


    matches.each do |match|
      # here we can identify the result and set it
      match.set_result(formatted_results[matches.index(match)])

      # print results
      puts "#{match.home_team} - #{match.away_team} #{match.result}"

      # save to database
      check = $collection.find({:home_team => match.home_team, :away_team => match.away_team}).first
      if check
        $collection.update_one({:home_team => match.home_team, :away_team => match.away_team},
                               {"$set" => {:result => match.result}})
        next
      else
        data = url.match(/spieltag\/(\d{4}-\d{2})\/(\d+)/)
        season = data[1]
        matchday = data[2]

        $collection.insert_one({:home_team => match.home_team, :away_team => match.away_team,
                                :result => match.result, :season => season, :matchday => matchday})
      end
    end
  rescue => exception
    puts "Error: #{exception}"
  end
end

seasons = [
  {:name => "2019-20"},
  {:name => "2020-21"},
  {:name => "2021-22"},
  {:name => "2022-23"},
  {:name => "2023-24"},
]

leagues = [
  {:name => "Bundesliga", :url => []},
  {:name => "2. Bundesliga", :url => []},
  {:name => "3. Liga", :url => []},
  {:name => "Premier League", :url => []},
  {:name => "La Liga", :url => []},
  {:name => "Serie A", :url => []},
]

seasons.each do |season|
  sname = season[:name]

  leagues.each do |league|
    league[:season] = sname
  end

  (1..34).each do |i|
    leagues[0][:url] << "https://www.kicker.de/bundesliga/spieltag/#{sname}/#{i}"
    leagues[1][:url] << "https://www.kicker.de/2-bundesliga/spieltag/#{sname}/#{i}"
  end

  (1..38).each do |i|
    leagues[2][:url] << "https://www.kicker.de/3-liga/spieltag/#{sname}/#{i}"
    leagues[3][:url] << "https://www.kicker.de/premier-league/spieltag/#{sname}/#{i}"
    leagues[4][:url] << "https://www.kicker.de/la-liga/spieltag/#{sname}/#{i}"
    leagues[5][:url] << "https://www.kicker.de/serie-a/spieltag/#{sname}/#{i}"
  end
end



leagues.each do |league|
  puts "\n"
  puts league[:name] + " from kicker.de: "
  league[:url].each do |url|
    puts "Matches from current matchday:" + url
    extract_data_from_league(url)
    puts "----------------------------------"
  end
end