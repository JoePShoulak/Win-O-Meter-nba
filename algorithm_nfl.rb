##################
#  Version 1.1   #
##################

require 'csv'

def algorithm(l1, l2) # Weighted Euclidean distance between two coordinates, dividing by the ratio of Std Dev from points and yards to turnovers (the min)
  dp = ( (l1[0]-l2[0])/8.0  )**2
  dy = ( (l1[1]-l2[1])/63.0 )**2
  dt = (  l1[2]-l2[2]       )**2
  return (dp + dy + dt)**(0.5)
end

season2014 = CSV.read('/Users/joe/Win O Meter/NFL2014.csv') # reference season
season2015 = CSV.read('/Users/joe/Win O Meter/NFL2015.csv') # season to be predicted

games = []
matchups = []

season2014[1..-1].each do |x|
  games += [{team: x[3], points: x[7].to_i, yards: x[9].to_i, turn: x[10].to_i}] # winning team (team 1)
  games += [{team: x[5], points: x[8].to_i, yards: x[11].to_i, turn: x[12].to_i}] # losing team (team 2)
end                                                                               # these are seperate to track individual play behavior of teams

season2015[1..-1].each do |x|
  matchups += [{team1: x[3], points1: x[7].to_i, yards1: x[9].to_i, turn1: x[10].to_i,
                team2: x[5], points2: x[8].to_i, yards2: x[11].to_i, turn2: x[12].to_i}] # matchup
end

correct = 0
error = 0
total = 0

matchups.each do |match| # For every matchup in the 2015 season...
  total += 1
  match_stats_1 = [match[:points1], match[:yards1], match[:turn1]] # match "game" 1
  match_stats_2 = [match[:points2], match[:yards2], match[:turn2]] # match "game" 2

  t1games = []  # t1games[i] = [distance_to_match_game, game_looked_up]
  t2games = []  # these are the games to be referenced to find the score of the game being predicted

  games.each do |game| # search all games (last season)
    game_stats = [game[:points], game[:yards], game[:turn]] # create "coordinate"
    case game[:team]
    when match[:team1]  # Find all games where this team played
      t1games += [[algorithm(match_stats_1, game_stats), game]]  # Add it to the list of games as a list of it's distance to the current game, then itself
    when match[:team2]
      t2games += [[algorithm(match_stats_2, game_stats), game]]
    end
  end
  begin # some arrays are misbehaving, this is to avoid an error in <5% of games. Assuming this will be unneccessary when using better API
    t1games.sort! # sort by distance to game breing predicted
    t2games.sort!
    g1 = t1games[0][1] # closest game, selecting the game
    g2 = t2games[0][1]
    p1 = g1[:points] # score of closest game
    p2 = g2[:points]
    puts "Matchup: #{match[:team1]} vs #{match[:team2]}"
    puts "\tTrue Score:\t#{match[:points1]}-#{match[:points2]}"
    puts "\tPredicition:\t#{p1}-#{p2}"
    puts "\tResult: \t#{p1 > p2}"
    correct += 1 if p1 > p2
  rescue
    puts "Error: Unable to predict outcome of game (unknown error)"
    error += 1
  end
  puts
end

puts "Total:    #{total}"
puts "Correct:  #{correct}"
puts "Error:    #{error}"
puts "Correct%: #{(100.0*correct/total).round(2)}%"
puts "Error%:   #{(100.0*error/total).round(2)}%"


