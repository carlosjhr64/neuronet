require 'neuronet'
MANY = 100_000

def network(i)
  ffn, name = nil, nil
  case i
  when 1
    ffn = Neuronet::FeedForward.new([2,1])
    name = '[2,1]'
  when 2
    ffn = Neuronet::FeedForward.new([2,3,1])
    name = '[2,3,1]'
  when 3
    ffn = Neuronet::FeedForward.new([2,3,1])
    Neuronet.tao(ffn)
    name = '[2,3,1] Tao'
  when 4
    ffn = Neuronet::FeedForward.new([2,3,1])
    Neuronet.tao(ffn)
    Neuronet::Yin.reweigh(ffn)
    Neuronet::Yang.reweigh(ffn)
    name = '[2,3,1] Tao-Yin-Yang'
  when 5
    ffn = Neuronet::FeedForward.new([2,3,2,1])
    Neuronet.tao(ffn)
    Neuronet::Yin.reweigh(ffn)
    Neuronet::Yang.reweigh(ffn)
    name = '[2,3,2,1] Tao-Yin-Yang'
  end
  return ffn, name
end

[
  ['Add',Proc.new{|a,b|a+b}],
  ['Subtract',Proc.new{|a,b|a-b}],
  ['Multiply',Proc.new{|a,b|a*b}],
].each do |name, f|
  1.upto(5) do |i|
    ffn, type = network(i)
    puts "#{name} with #{type} #{MANY} times trained."
    MANY.times do
      input = [rand-rand, rand-rand] # creates [(-1,1), (-1,1)]
      target = [f.call(input[0], input[1])]
      ffn.exemplar(input, target)
    end
    3.times do
      input = [rand-rand, rand-rand].map{|x| x.round(3)}
      target = [f.call(input[0], input[1])].map{|x| x.round(3)}
      ffn.set(input)
      puts "  #{input.join(",\t")}\t=> #{target.join(', ')}\t\t#{ffn.output.map{|x| x.round(3)}.join(', ')}"
    end
  end
  puts <<EOT
I've yet to observe any of the provided architectures do multiplication.
If you figure out an network architecture that can to multiplication,
email me a description of it at carlosjhr64@gmail.com.
EOT
end
