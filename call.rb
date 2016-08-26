require 'json'

schedule = JSON.parse(`curl http://api.sportradar.us/nfl-ot1/games/2015/REG/schedule.json?api_key=5etueuh9u3a8auueywb7pesw`)

game_ids = []

schedule["weeks"].each do |w|
  w["games"].each do |g|
    game_ids +=  [g["id"]]
  end
end

puts game_ids.length

game = JSON.parse(`curl http://api.sportradar.us/nfl-ot1/games/#{game_ids[0]}/statistics.json?api_key=5etueuh9u3a8auueywb7pesw`)

puts "#{game["summary"]["home"]["market"]} #{game["summary"]["home"]["name"]}:"
puts "\t Points:    \t#{game["summary"]["home"]["points"]}"
puts "\t Yards:     \t#{game["statistics"]["home"]["summary"]["total_yards"]}"
puts "\t Turnovers: \t#{game["statistics"]["home"]["summary"]["turnovers"]}"
puts "#{game["summary"]["away"]["market"]} #{game["summary"]["away"]["name"]}:"
puts "\t Points:    \t#{game["summary"]["away"]["points"]}"
puts "\t Yards:     \t#{game["statistics"]["away"]["summary"]["total_yards"]}"
puts "\t Turnovers: \t#{game["statistics"]["away"]["summary"]["turnovers"]}"


