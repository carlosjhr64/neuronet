# frozen_string_literal: true

# Neuronet module / FeedForward class
module Neuronet
  # A Feed Forward Network
  class FeedForward < Array
    attr_reader :entrada, :salida, :yin, :yang
    attr_accessor :learning

    # I find very useful to name certain layers:
    #  [0]    @entrada   Input Layer
    #  [1]    @yin       Typically the first middle layer
    #  [-2]   @yang      Typically the last middle layer
    #  [-1]   @salida    Output Layer
    def initialize(layers)
      length = layers.length
      raise 'Need at least 2 layers' if length < 2

      super(length)
      self[0] = Neuronet::InputLayer.new(layers[0])
      1.upto(length - 1) do |index|
        self[index] = Neuronet::Layer.new(layers[index])
        self[index].connect(self[index - 1])
      end
      @entrada  = first
      @salida   = last
      @yin      = self[1]
      @yang     = self[-2]
      @learning = 1.0 / (length - 1)
    end

    def number(num)
      mju = Math.sqrt(num) * (length - 1)
      @learning = 1.0 / mju
    end

    # Set the input layer.
    def set(input)
      @entrada.set(input)
      self
    end

    def input
      @entrada.values
    end

    # Update the network.
    def update
      # update up the layers
      1.upto(length - 1) { |index| self[index].partial }
      self
    end

    def output
      @salida.values
    end

    # Consider:
    #   m = Neuronet::FeedForward.new(layers)
    # Want:
    #   output = m * input
    def *(other)
      set(other)
      update
      @salida.values
    end

    def train(target)
      @salida.train(target, @learning)
      self
    end

    def pairs(pairs)
      pairs.shuffle.each { |input, target| set(input).update.train(target) }
      if block_given?
        while yield
          pairs.shuffle.each do |input, target|
            set(input).update.train(target)
          end
        end
      end
      self
    end

    def inspect
      "#learning:#{Neuronet.format % @learning}\n" + map(&:inspect).join("\n")
    end

    def to_s
      map(&:to_s).join("\n")
    end

    class << self
      attr_accessor :color, :colorize
    end

    COLORIZED = ''.respond_to? :colorize
    COLOR = lambda do |v|
      c = nil
      if COLORIZED
        c = :light_white
        if v > 1.0
          c = :green
        elsif v < -1.0
          c = :red
        elsif v < 0.0
          c = :white
        end
      else
        c = :white
        if v > 1.0
          c = :green
        elsif v < -1.0
          c = :red
        elsif v < 0.0
          c = :gray
        end
      end
      c
    end
    FeedForward.color = COLOR
    COLORIZE = ->(s, c) { COLORIZED ? s.colorize(color: c) : s.color(c) }
    FeedForward.colorize = COLORIZE

    def colorize(verbose: false, nodes: false, biases: true, connections: true)
      parts = inspect.scan(/[: ,|+*\n]|[^: ,|+*\n]+/)
      each do |layer|
        layer.each do |node|
          l = node.label
          v = node.value
          0.upto(parts.length - 1) do |i|
            case parts[i]
            when l
              parts[i] = FeedForward.colorize[l, FeedForward.color[v]] if nodes
            when '|'
              if biases
                parts[i] = FeedForward.colorize[
                  '|', FeedForward.color[parts[i + 1].to_f]
                ]
              end
            when '*'
              if connections
                parts[i] = FeedForward.colorize[
                  '*', FeedForward.color[parts[i - 1].to_f]
                ]
              end
            end
          end
        end
      end
      parts.delete_if { _1 =~ /^[\d.+-]+$/ } unless verbose
      parts.join
    end
  end
end
