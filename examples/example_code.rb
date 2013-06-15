gem 'neuronet' '~> 5.0'
require 'neuronet'

# Math::sin(x) cycles from 0.0 at x=0.0,
# up to 1.0 at x=Math::PI/2.0,
# back down to 0.0 at x=Math::PI (may be off by a computational error),
# down to -1.0 at x=3.0*Math::PI/2.0,
# and back up to 0.0 at x=2.0*Math::PI.
# The entire cycle is:
cycle = 2.0*Math::PI

# I'll use cycle to scale my random number
random = Proc.new { cycle_rand = cycle*rand }

# I'll make this a input, output layer feed forward network.
# I've found a middle layer un-nescessary for this problem.
input_layers = 20
output_layers = 5


# computation time... maximum number of iterations before calling it quits!
max_count = 1_000_000

level, amplitude, afrequency = random.call, random.call, random.call
function = Proc.new{|phase,t| level + amplitude*Math::sin(phase + afrequency*t) }
puts "Function(phase,t) = #{level.round(3)} + #{amplitude.round(3)}*Sin(phase + #{afrequency.round(3)}*t)"
puts "Cycle step = #{(afrequency/cycle).round(3)}"

ffnet = Neuronet::ScaledNetwork.new([input_layers, output_layers])
# We're trying to train a function, so there's no noise
# to smooth out over a number of data points.
ffnet.learning = 0.7 # ~ 1.0/sqrt(1.0+N), where N=1

# Training...
mma = amplitude # moving average set high to be averaged down.
count = 0
while (mma/amplitude > 0.01) && (count < max_count) do # looking for 1%, but quit if it's taking too long
  count += 1
  print '.' if count%100 == 0
  phase = random.call # any random starting point for the series
  input = 0.upto(input_layers-1).inject([]){|v,t| v.push( function.call(phase,t) ) }
  ffnet.reset(input) # reset sets both ffnet and distribution
  guess = ffnet.output
  # NaN error check.  Still need to figure out why this happens sometimes...
  raise "Got NaN" if guess.inject(false){|v,x| v ||= true if x.nan? }
  output = input_layers.upto(input_layers+output_layers-1).inject([]){|v,t| v.push( function.call(phase,t) ) }
  error2 = 0.upto(4).map{|i| guess[i] - output[i] }.inject(0.0){|v,x| v+=x*x } / 5.0 # five points!
  # Note that the real task is to describe the motion (deviation) from level
  mma = (99.0*mma + Math.sqrt(error2)) / 100.0
  mma = amplitude if mma > amplitude
  ffnet.train!(output) # ffnet trains the output
end
puts
puts "Iterations:\t#{count}"
# How good are we?
error2 = 0.0
sample = 100
sample.times do
  phase = random.call # any random starting point for the series
  input = 0.upto(input_layers-1).inject([]){|v,t| v.push( function.call(phase,t) ) }
  ffnet.reset(input)
  guess = ffnet.output
  output = input_layers.upto(input_layers+output_layers-1).inject([]){|v,t| v.push( function.call(phase,t) ) }
  error2 += 0.upto(4).map{|i| guess[i] - output[i]}.inject(0.0){|v,x| v+=x*x} # five points! Divided out below...
end

std = Math::sqrt( error2 / (5.0*sample-1.0) ) # note that for every interation, there were five points!
relative = std / amplitude

puts "Relative Error (std/amplitude): #{(100.0*relative).round(2)}%\tStandard Deviation: #{std.round(3)}"
puts "Examples:"
3.times do
  phase = random.call # any random starting point for the series
  input = 0.upto(input_layers-1).inject([]){|v,t| v.push( function.call(phase,t) ) }
  ffnet.reset(input)
  guess = ffnet.output
  output = input_layers.upto(input_layers+output_layers-1).inject([]){|v,t| v.push( function.call(phase,t) ) }
  puts
  puts "\tInput:\t#{input.map{|x| x.round(3) }.join(', ')}"
  puts "\tOutput:\t#{output.map{|x| x.round(3) }.join(', ')}"
  puts "\tGuess:\t#{guess.map{|x| x.round(3) }.join(', ')}"
end
puts
