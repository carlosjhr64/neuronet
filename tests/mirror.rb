require 'neuronet'
include Neuronet

# This tests YinYang's mirror.

yinyang = YinYang.bless FeedForward.new( [3, 3, 3] )
input = [-1.0, 0.0, 1.0]
yinyang.set(input)

puts "### YinYang ###"
puts "Input:"
puts input.join(",\t")

puts "In:"
puts yinyang.in.map{|x| x.activation}.join(",\t")

# Yin and Yang are one and the same middle layer.
puts "Yin/Yang:"
puts yinyang.yin.map{|x| x.activation}.join(",\t")
puts yinyang.yang.map{|x| x.activation}.join(",\t")

puts "Out:"
puts yinyang.out.map{|x| x.activation}.join(",\t")

puts "Output:"
puts yinyang.output.join(",\t")

puts
puts

brahma = BrahmaYang.bless FeedForward.new( [3, 6, 6] )
input = [-1.0, 0.0, 1.0]
brahma.set(input)

puts "### BrahmaYang ###"
puts "Input:"
puts input.join(",\t")

puts "In:"
puts brahma.in.map{|x| x.activation}.join(",\t")

# Yin and Yang are one and the same middle layer.
puts "Yin/Yang:"
puts brahma.yin.map{|x| x.activation}.join(",\t")
puts brahma.yang.map{|x| x.activation}.join(",\t")

puts "Out:"
puts brahma.out.map{|x| x.activation}.join(",\t")

puts "Output:"
puts brahma.output.join(",\t")
