require 'neuronet'

# Math::sin(x) cycles from 0.0 at x=0.0,
# up to 1.0 at x=Math::PI/2.0,
# back down to 0.0 at x=Math::PI (may be off by a computational error),
# down to -1.0 at x=3.0*Math::PI/2.0,
# and back up to 0.0 at x=2.0*Math::PI.
# The entire cycle is:
CYCLE = 2.0*Math::PI

# I'll use CYCLE to scale my random number
def random
  CYCLE*rand
end

# I'll make this an [INPUTS, OUTPUTS] layer feed forward network.
# I've found a middle layer un-nescessary for this problem.
INPUTS = 20
OUTPUTS = 5

# computation time... maximum number of iterations before calling it quits!
MAX = 1_000_000

# Radomly set the sine function's parameters
A, B, D = random, random, random

# The randomly parametized sine function, f.
def f(phase, t)
  A + B*Math::sin(phase + D*t)
end

# Feedback on what the function is.
puts "f(phase, t) = #{A.round(3)} + #{B.round(3)}*Sin(phase + #{D.round(3)}*t)"
puts "Cycle step = #{(D/CYCLE).round(3)}"

neuronet = Neuronet::ScaledNetwork.new([INPUTS, OUTPUTS])
# We're trying to train a function, so there's no noise
# to smooth out over a number of data points.
neuronet.num(1.0)

# Training...
mma = B # moving average set high to be averaged down.
count = 0
while (mma/B > 0.01) && (count < MAX) do # looking for 1%, but quit if it's taking too long
  count += 1
  print '.' if count%5000 == 0 # just to let us know it's iterating...
  phase = random # any random starting point for the series
  input = 0.upto(INPUTS-1).inject([]){|v,t| v.push( f(phase,t) ) }
  neuronet.reset(input) # reset sets both neuronet and distribution
  output = neuronet.output
  # I don't think I get NaN anymore, but checking...
  # raise "Got NaN" if output.inject(false){|v,x| v ||= true if x.nan? }
  # A NaN would be a bug.  It was a bug b/4.
  target = INPUTS.upto(INPUTS+OUTPUTS-1).inject([]){|v,t| v.push( f(phase,t) ) }
  error2 = 0.upto(4).map{|i| output[i] - target[i] }.inject(0.0){|v,x| v+=x*x } / 5.0 # five points!
  # Note that the real task is to describe the motion (deviation) from A
  mma = (127.0*mma + Math.sqrt(error2)) / 128.0
  mma = B if mma > B
  neuronet.train!(target) # neuronet trains the output
end

# How good are we?
puts
puts "Iterations:\t#{count}"
error2 = 0.0
sample = 100
sample.times do
  phase = random # any random starting point for the series
  input = 0.upto(INPUTS-1).inject([]){|v,t| v.push( f(phase,t) ) }
  neuronet.reset(input)
  output = neuronet.output
  target = INPUTS.upto(INPUTS+OUTPUTS-1).inject([]){|v,t| v.push( f(phase,t) ) }
  error2 += 0.upto(4).map{|i| output[i] - target[i]}.inject(0.0){|v,x| v+=x*x} # five points! Divided out below...
end

std = Math::sqrt( error2 / (5.0*sample-1.0) ) # note that for every interation, there were five points!
relative = std / B

puts "Relative Error (std/B): #{(100.0*relative).round(2)}%\tStandard Deviation: #{std.round(3)}"
puts "Examples:"
3.times do
  phase = random # any random starting point for the series
  input = 0.upto(INPUTS-1).inject([]){|v,t| v.push( f(phase,t) ) }
  neuronet.reset(input)
  output = neuronet.output
  target = INPUTS.upto(INPUTS+OUTPUTS-1).inject([]){|v,t| v.push( f(phase,t) ) }
  puts
  puts "Input:\t#{input.map{|x| x.round(3) }.join(', ')}"
  puts "Target:\t#{target.map{|x| x.round(3) }.join(', ')}"
  puts "Output:\t#{output.map{|x| x.round(3) }.join(', ')}"
end
puts
