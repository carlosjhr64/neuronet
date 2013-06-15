require 'neuronet'
MANY = 50_000

# Because our real world space is the Real numbers,
# define -1 (negative numbers) to be false,
# and +1 (positive numbers) to be true.

data_or = [
  [[-1, -1], [-1]],	# F or F is F
  [[ 1, -1], [ 1]],	# T or F is T
  [[-1,  1], [ 1]],	# F or T is T
  [[ 1,  1], [ 1]],	# T or T is T
]

data_and = [
  [[-1, -1], [-1]],	# F and F is F
  [[ 1, -1], [-1]],	# T and F is F
  [[-1,  1], [-1]],	# F and T is F
  [[ 1,  1], [ 1]],	# T and T is T
]

data_xor = [
  [[-1, -1], [-1]],	# F xor F is F
  [[ 1, -1], [ 1]],	# T xor F is T
  [[-1,  1], [ 1]],	# F xor T is T
  [[ 1,  1], [-1]],	# T xor T is F
]

[[data_or,'OR'],[data_and,'AND'],[data_xor,'XOR']].each do |data,name|
  puts "#{name} with [2,1] #{MANY} times trained."
  ffn = Neuronet::FeedForward.new([2,1])
  MANY.times do
    data.each do |input, target|
      ffn.exemplar(input, target)
    end
  end
  data.each do |input, target|
    ffn.set(input)
    puts "#{input.join(",\t")}\t\t#{ffn.output.map{|x| x.round(3)}.join(', ')}"
  end

  puts "#{name} with [2,2,1] #{MANY} times trained."
  ffn = Neuronet::FeedForward.new([2,2,1])
  MANY.times do
    data.each do |input, target|
      ffn.exemplar(input, target)
    end
  end
  data.each do |input, target|
    ffn.set(input)
    puts "#{input.join(",\t")}\t\t#{ffn.output.map{|x| x.round(3)}.join(', ')}"
  end

  puts "#{name} with [2,2,1] #{MANY} times trained with Tao."
  ffn = Neuronet::FeedForward.new([2,2,1])
  ffn.out.connect(ffn.in)
  MANY.times do
    data.each do |input, target|
      ffn.exemplar(input, target)
    end
  end
  data.each do |input, target|
    ffn.set(input)
    puts "#{input.join(",\t")}\t\t#{ffn.output.map{|x| x.round(3)}.join(', ')}"
  end

end
