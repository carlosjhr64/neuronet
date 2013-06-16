require 'neuronet'
MANY = 10_000

def network(i)
  ffn, name = nil, nil
  case i
  when 1
    ffn = Neuronet::FeedForward.new([2,1])
    name = '[2,1]'
  when 2
    ffn = Neuronet::FeedForward.new([2,2,1])
    name = '[2,2,1]'
  when 3
    ffn = Neuronet::FeedForward.new([2,2,1])
    Neuronet.tao(ffn)
    name = '[2,2,1] Tao'
  when 4
    ffn = Neuronet::FeedForward.new([2,2,1])
    Neuronet.tao(ffn)
    Neuronet::Yin.reweigh(ffn)
    Neuronet::Yang.reweigh(ffn)
    name = '[2,2,1] Tao-Yin-Yang'
  end
  return ffn, name
end

# Because our problem space is the Real numbers,
# define -1 (negative numbers) to be false,
# and +1 (positive numbers) to be true.

data_or = [
  [[-1, -1], [-1]],	# F or F is F
  [[ 1, -1], [ 1]],	# T or F is T
  [[-1,  1], [ 1]],	# F or T is T
  [[ 1,  1], [ 1]],	# T or T is T
			# Extra for balance
  [[-1, -1], [-1]],	# F or F is F
]

data_and = [
  [[-1, -1], [-1]],	# F and F is F
  [[ 1, -1], [-1]],	# T and F is F
  [[-1,  1], [-1]],	# F and T is F
  [[ 1,  1], [ 1]],	# T and T is T
			# Extra for balance
  [[ 1,  1], [ 1]],	# T and T is T
]

data_xor = [
  [[-1, -1], [-1]],	# F xor F is F
  [[ 1, -1], [ 1]],	# T xor F is T
  [[-1,  1], [ 1]],	# F xor T is T
  [[ 1,  1], [-1]],	# T xor T is F
]

[[data_or,'OR'],[data_and,'AND'],[data_xor,'XOR']].each do |data,name|
  1.upto(4) do |i|
    ffn, type = network(i)
    puts "#{name} with #{type} #{MANY} times trained."
    MANY.times do
      data.shuffle.each do |input, target|
        ffn.exemplar(input, target)
      end
    end
      data.each do |input, target|
      ffn.set(input)
      puts "#{input.join(",\t")}\t=> #{target.join(', ')}\t\t#{ffn.output.map{|x| x.round(3)}.join(', ')}"
    end
  end
end
