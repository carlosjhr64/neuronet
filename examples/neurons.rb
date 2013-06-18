require 'neuronet'
include Neuronet

def random
  rand - rand
end

# create the input nodes
a = Node.new
b = Node.new

# create the output neuron
sum = Neuron.new

# and a neuron on the side
adjuster = Neuron.new

# connect the adjuster to a and b
adjuster.connect(a)
adjuster.connect(b)

# connect sum to a and b
sum.connect(a)
sum.connect(b)
# and to the adjuster
sum.connect(adjuster)

# The learning constant is about...
learning = 0.1

# Train the tiny network
10_000.times do
  a.value = x = random
  b.value = y = random
  target = x+y
  output = sum.update
  sum.backpropagate(learning*(target-output))
end

# Let's see how well the training went
10.times do
  a.value = x = random
  b.value = y = random
  target = x+y
  output = sum.update
  puts "#{x.round(3)} + #{y.round(3)} = #{target.round(3)}"
  puts "  Neuron says #{output.round(3)}, #{(100.0*(target-output)/target).round(2)}% error."
end
