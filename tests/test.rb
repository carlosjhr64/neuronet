require 'neuronet'

### Squash/UnSquash ###
raise "Expected version 6.0.0" unless Neuronet::VERSION == '6.0.0'
raise "Bad Squash 0.0" unless Neuronet.squash(0.0) == 0.5
raise "Bad Squash 1.0" unless Neuronet.squash(1.0).round(3) == 0.731
raise "Bad Squash -1.0" unless Neuronet.squash(-1.0).round(3) == 0.269
raise "Bad UnSquash 0.5" unless Neuronet.unsquash(0.5) == 0.0
raise "Bad UnSquash 0.731" unless Neuronet.unsquash(0.731).round(3) == 1.0
raise "Bad UnSquash 0.269" unless Neuronet.unsquash(0.269).round(3) == -1.0

### Noise ###
sum = 0.0
n = 10_000
n.times do
  sum += Neuronet.noise
end
# Everyonce in a while by chage, this will happen.
raise "Noise not averaging to one? (Happens sometimes)" unless (sum/n.to_f).round(2) == 1
sum = 0.0
n.times do
  sum += (1.0 - Neuronet.noise)**2.0
end
std = Math.sqrt(sum/n.to_f)
raise "Standard Deviation in noise not 0.29?" unless std.round(2) == 0.29


### Node ###
node = Neuronet::Node.new
raise "Bad node value" unless node.value == 0.0
raise "Bad node activation" unless node.activation == 0.5
raise "Bad node updated" unless node.update == 0.5
raise "Bad node backpropagate" unless node.backpropagate(0.1) == nil
node = Neuronet::Node.new(1.0)
raise "Bad node value" unless node.value.round(3) == 1.0
raise "Bad node activation" unless node.activation.round(3) == 0.731
raise "Bad node updated" unless node.update.round(3) == 0.731

### Connection ###
conn = Neuronet::Connection.new(node)
raise "Bad connection weight" unless conn.weight == 0.0
raise "Bad connection node" unless conn.node == node
raise "Bad connection value" unless conn.value == 0.0
# and a quick sanity check
raise "Bad connection node" unless conn.node.activation == node.activation
conn = Neuronet::Connection.new(node, 1.0)
raise "Bad connection weight" unless conn.weight == 1.0
raise "Bad connection value" unless conn.value == node.activation # * 1.0
raise "Bad connection update" unless conn.update == node.activation # stayed the same, of course.
# Positive error increments weight
w = conn.weight
conn.backpropagate(0.1)
raise "Positive error did not increment weight" unless conn.weight > w
w = conn.weight
conn.backpropagate(-0.1)
raise "Negative error did not decrease weight" unless conn.weight < w

### Neuron ###
neuron = Neuronet::Neuron.new
# Just checking methods exist, really...
raise "Connections to neuron now?"  unless neuron.connections.length == 0
raise "Bad neuron bias"  unless neuron.bias == 0.0
# IDK how to unit test the following methods... without a lot of work.
# Will just test by behavior later.
raise "Missing partial?" unless neuron.respond_to?(:partial)
raise "Missing backpropagate?" unless neuron.respond_to?(:backpropagate)
raise "Missing connect?" unless neuron.respond_to?(:connect)

### InputLayer ###
input = Neuronet::InputLayer.new(5)
raise "Bad InputLayer length" unless input.length == 5
raise "Bad InputLayer terminal node" unless input.first.class == Neuronet::Node

### Layer ###
layer = Neuronet::Layer.new(6)
raise "Bad Layer length" unless layer.length == 6
raise "Bad layer neuron" unless layer.first.class == Neuronet::Neuron
layer.connect(input)
raise "Where's the input node?" unless layer.last.connections.last.node.class == Neuronet::Node
# Will test the partial and train by behavior later
raise "Missing partial?" unless layer.respond_to?(:partial)
raise "Missing train?" unless layer.respond_to?(:train)
raise "Bad layer values?" unless layer.values == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

### FeedForward ###
ffn = Neuronet::FeedForward.new([4,3,2])
mu = 1 + 4 + 4*3 + 3 + 3*2
raise "WUT IZZ MU???" unless ffn.mu == mu
ffn.muk=0.5
raise "What the muk!?" unless ffn.learning == 0.5/mu
ffn.num=2.0
raise "Num num!?" unless ffn.learning == 1.0/(Math.sqrt(1.0 + 2.0) * mu)
ffn.learning = 0.0123
raise "Could not set learing constant." unless ffn.learning == 0.0123
raise "ffn.in is not InputLayer?" unless ffn.in.class == Neuronet::InputLayer
raise "ffn.out is not Layer?" unless ffn.out.class == Neuronet::Layer
# the rest of FeedForwardNetwork to be tested by behavior.
[:update, :set, :train!, :exemplar, :input, :output].each do |symbol|
  raise "ffn does not respond to #{symbol}." unless ffn.respond_to?(symbol)
end

### Scale ###
scale = Neuronet::Scale.new
raise "bad scale center" unless scale.center == nil
raise "bad scale spread" unless scale.spread == nil
scale.set([0,1,2,3,4,5,6,7,8,9,10])
raise "Unexpected spread" unless scale.spread == 5
raise "Unexpected center" unless scale.center == 5
mapped = scale.mapped([0,1,2,3,4,5,6,7,8,9,10])
raise "mapped first should be -1" unless mapped.first == -1.0
raise "mapped last should be 1" unless mapped.last == 1.0
raise "Could not unmap" unless scale.unmapped(mapped).map{|x| x.round(3)} == [0,1,2,3,4,5,6,7,8,9,10]

### Gaussian ###
scale = Neuronet::Gaussian.new
raise "bad scale center" unless scale.center == nil
raise "bad scale spread" unless scale.spread == nil
scale.set([0,1,2,3,4,5,6,7,8,9,10])
raise "Unexpected spread" unless scale.spread.round(1) == 3.3
raise "Unexpected center" unless scale.center == 5
mapped = scale.mapped([0,1,2,3,4,5,6,7,8,9,10])
raise "mapped first should be -1" unless mapped.first.round(1) == -1.5
raise "mapped last should be 1" unless mapped.last.round(1) == 1.5
raise "Could not unmap" unless scale.unmapped(mapped).map{|x| x.round(3)} == [0,1,2,3,4,5,6,7,8,9,10]

### LogNormal ###
scale = Neuronet::LogNormal.new
raise "bad scale center" unless scale.center == nil
raise "bad scale spread" unless scale.spread == nil
scale.set([1.0,2.0,4.0,8.0,16.0,32.0,64.0,256.0])
raise "Unexpected spread" unless scale.spread.round(2) == 1.85
raise "Unexpected center" unless scale.center.round(2) == 2.51
mapped = scale.mapped([1.0,2.0,4.0,8.0,16.0,32.0,64.0,256.0])
raise "mapped first should be -1" unless mapped.first.round(2) == -1.36
raise "mapped last should be 1" unless mapped.last.round(2) == 1.64
raise "Could not unmap" unless scale.unmapped(mapped).map{|x| x.round(3)} == [1.0,2.0,4.0,8.0,16.0,32.0,64.0,256.0]

# I'm going to gloss over the rest because
# they mostly depend on stuff already tested above.

### ScaledNetwork ###
ffn = Neuronet::ScaledNetwork.new([8,5,3])
raise "ScaledNetwork should have Guassian." unless ffn.distribution.class == Neuronet::Gaussian
raise "ScaledNetwork should respond to reset" unless ffn.respond_to?(:reset)

### Tao ###
ffn = Neuronet::Tao.new([6,5,4,3,2])
mu = 1 + 6 + 6*5 + 5 + 5*4 + 4 + 4*3 + 3 + 3*2 + 6*2
raise "MU???" unless ffn.mu == mu
raise "Yin should be a layer." unless ffn.yin.class == Neuronet::Layer
raise "Yin should be the first middle layer" unless ffn.yin.length == 5
raise "Yang should be a layer." unless ffn.yang.class == Neuronet::Layer
raise "Yang should be the last middle layer." unless ffn.yang.length == 3
# a quick sanity check
raise "The last layer should be the output layer" unless ffn.out == ffn.last
unless ffn.last.last.connections.last.node.class == Neuronet::Node
  # Remember the Node is a terminal in InputLayer.
  raise "The output layer should be connected to the input layer."
end

### Yin ###
complained = false
begin
  ffn = Neuronet::Yin.new([5,3,3])
rescue Exception
  complained = true
end
raise "Should have complained about Input longer than Yin" unless complained
ffn = Neuronet::Yin.new([3,3,3])
0.upto(ffn.yin.length-1) do |i|
  raise "Yin is supposed to initially mirror input" unless ffn.yin[i].connections[i].weight == 1
end

### Yang ###
complained = false
begin
  ffn = Neuronet::Yang.new([3,3,5])
rescue Exception
  complained = true
end
raise "Should have complained about Output longer than Yang" unless complained
ffn = Neuronet::Yang.new([3,3,3])
0.upto(ffn.out.length-1) do |i|
  raise "Output is supposed to initially mirror Yang" unless ffn.out[i].connections[i].weight == 1
end

### YinYang ###
ffn = Neuronet::YinYang.new([4,4,4])
# It works... I know it does.  :P

### Bless to Tao ###
ffn = Neuronet::FeedForward.new([5,4,3])
mu1 = ffn.mu
Neuronet.tao(ffn)
mu2 = ffn.mu
raise "mu should have upgraded" unless mu2 - mu1 = 5*3
