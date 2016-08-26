require 'csv'

module Enumerable

    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def sample_variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def stdev
      return Math.sqrt(self.sample_variance)
    end

end 

season2015 = CSV.read('/Users/joe/Win O Meter/NFL2015.csv') # season to be predicted

points = []
yards = []
turn = []

season2015[1..-1].each do |x|
  points  += [ x[7].to_i,  x[8].to_i  ]
  yards   += [ x[9].to_i,  x[11].to_i ]
  turn    += [ x[10].to_i, x[12].to_i ]
end

puts "Points:"
puts "  Mean:    #{points.mean.round(2)}"
puts "  Std Dev: #{points.stdev.round(2)} (#{(points.stdev/turn.stdev).round}x over Turnovers)"
puts "Yards:"
puts "  Mean:    #{yards.mean.round(2)}"
puts "  Std Dev: #{yards.stdev.round(2)} (#{(yards.stdev/turn.stdev).round}x over Turnovers)"
puts "Turnovers:"
puts "  Mean:    #{turn.mean.round(2)}"
puts "  Std Dev: #{turn.stdev.round(2)}"

