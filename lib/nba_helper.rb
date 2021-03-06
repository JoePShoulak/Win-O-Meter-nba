require 'json'

# The algorithm
def algorithm(subgame1, subgame2) # Currently, just points is better, so I'm not using this method
  #l1 = subgame1.stats
  #l2 = subgame2.stats
  #dp = ( ( l1[0]-l2[0] )/8.0  )**2
  #dy = ( ( l1[1]-l2[1] )/63.0 )**2
  #dt = 0#(   l1[2]-l2[2]        )**2
  
  #return (dp + dy + dt)**(0.5)  Right now just points is better
  
  return (subgame1.points - subgame2.points).abs
end

# Classes
class Subgame
  def initialize(name="", points=0, final_score=nil, id=nil, win_percentage=nil)
    @name   = name
    @points = points.to_i
    @final_score  = final_score.to_i
    @id=id
  end
  
  attr_accessor :name, :points, :final_score, :id, :win_percentage  
  
  def score
    return [self.name, self.points]
  end
  
  def distance_to(game)
    return algorithm(self, game)
  end
  
  def find_closest(list_of_games)
    return list_of_games.sort_by { |g| self.distance_to g }[0]
  end
  
  def same_as?(game)
    return self.id == game.id
  end
end

class Match
  def initialize(subgame1, subgame2, true_winner=nil, true_tie=nil)
    @subgame1 = subgame1
    @subgame2 = subgame2
    @true_winner = true_winner
    @true_tie = true_tie
    
    
    self.subgame1.win_percentage = 100*(0.5 + self.spread/40.0)
    self.subgame2.win_percentage = 100 - self.subgame1.win_percentage
  end
  
  attr_accessor :subgame1, :subgame2, :true_winner, :true_tie
  
  def subgames
    return [@subgame1, @subgame2]
  end
  
  def tie?
    self.subgame1.points == self.subgame2.points
  end
  
  def winner
    return self.tie? ? nil : self.subgames.max_by { |g| g.points }
  end
  
  def loser
    return self.tie? ? nil : self.subgames.min_by { |g| g.points }
  end
  
  def info
    return self.subgame1.info + self.subgame2.info
  end
  
  def spread
    return self.subgame1.points - self.subgame2.points
  end
end

# Misc.
def clear_line
  print "\r" + " "*100 + "\b"*100
end

# Parse game
def process(game, periods_testing)
  subgame_home = Subgame.new
  subgame_away = Subgame.new 
    
  subgame_home.id = game["id"]
  subgame_away.id = game["id"]
  
  begin
    subgame_home.name = game["home"]["market"] + " " + game["home"]["name"]
    subgame_away.name = game["away"]["market"] + " " + game["away"]["name"]
  rescue Exception => msg
    puts msg
    puts game
  end
    
  game["periods"].length.times do |pe| # For each period
    period = game["periods"][pe]
    
    home_points = period["scoring"]["home"]["points"].to_i
    away_points = period["scoring"]["away"]["points"].to_i
    
    subgame_home.points += home_points unless pe >= periods_testing
    subgame_away.points += away_points unless pe >= periods_testing
    
    subgame_home.final_score += home_points
    subgame_away.final_score += away_points
  end
    
  m = Match.new(subgame_home, subgame_away)
  
  m.true_winner = [subgame_home, subgame_away].sort_by { |s| s.final_score }[1]
  m.true_tie = ( subgame_home.final_score == subgame_away.final_score )
      
  return m
end

# Parse season
def json_load(json_file, periods_testing)
  processed_games = []
  
  games = JSON.parse(File.read(json_file)).select { |g| g["status"] == "closed" }

  games.each do |g|
    processed_games << process(g, periods_testing)
  end
  
  return processed_games
end

# Load files
def load_reference(periods_testing)
  print "Loading Reference File"
  
  matches = json_load("./data/radar2014.json", periods_testing)
  subgames = matches.map { |m| m.subgames }.flatten
  
  clear_line
  
  return subgames
end

def load_testing(periods_testing)
  print "Loading Testing File..."
  
  matches = json_load("./data/radar2015.json", periods_testing)
  
  clear_line
  
  return matches
end
