require 'json'
require './lib/nba_helper'

if ARGV.empty?
  puts "Error: Needs a year"
  exit
end

year = ARGV[0]

print "Loading Schedule..."
print "\b"*30

begin
  schedule = JSON.parse(`curl -s 	http://api.sportradar.us/nba-t3/games/#{year}/REG/schedule.json?api_key=uqpj2aeucyf5erk28py2xzqu`)
rescue Exception => msg
  if msg.message.include? 'Developer Over Rate'
    puts "Error: Too many queries this month"
  else
    puts msg.message
  end
  exit
end


game_ids = []

schedule["games"].each do |g|
  game_ids +=  [g["id"]]
end

n = 1
l = game_ids.length

games = []

clear_line

game_ids = game_ids[0..150] # Testing purposes
l = 150

game_ids.each do |id|
  print "Loading game #{n}/#{l} (#{(100.0*n/l).round}%)..."
  n += 1
  begin
    game = JSON.parse(`curl -s http://api.sportradar.us/nba-t3/games/#{id}/pbp.json?api_key=uqpj2aeucyf5erk28py2xzqu`)
  rescue Exception => msg
    if msg.message.include? 'Developer Over Rate'
      puts "Error: Too many queries this month"
      exit
    elsif msg.message.include? 'Developer Over Qps'
      sleep 1
      game = JSON.parse(`curl -s http://api.sportradar.us/nba-t3/games/#{id}/pbp.json?api_key=uqpj2aeucyf5erk28py2xzqu`)
    else 
      puts msg.message
      game = nil
    end
  end
  print "\b"*30
  games += [game]
  
  clear_line
end

games = games.select { |g| !g.nil? }

print "Saving games..."

f = File.open("./data/radar#{year}.json", "w")
f.write games.to_json

clear_line

print "Games saved."
