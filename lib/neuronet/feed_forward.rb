# frozen_string_literal: true

# Neuronet module / FeedForward class
module Neuronet
  # A Feed Forward Network
  class FeedForward < Array
    attr_reader :entrada, :salida, :yin, :yang

    # I find very useful to name certain layers:
    #  [0]    @entrada   Input Layer
    #  [1]    @yin       Typically the first middle layer
    #  [-2]   @yang      Typically the last middle layer
    #  [-1]   @salida    Output Layer
    def initialize(layers)
      length = layers.length
      raise 'Need at least 2 layers' if length < 2

      super(length) { Layer.new(layers[_1]) }
      1.upto(length - 1) { self[_1].connect(self[_1 - 1]) }
      @entrada  = first
      @salida   = last
      @yin      = self[1]
      @yang     = self[-2]
    end

    # Set the input layer.
    def set(input)
      @entrada.set(input)
      self
    end

    def input = @entrada.values

    # Update the network.
    def update
      # update up the layers
      1.upto(length - 1) { self[_1].partial }
      self
    end

    def output = @salida.values

    # Consider:
    #   m = Neuronet::FeedForward.new(layers)
    # Want:
    #   output = m * input
    def *(other)
      set(other)
      update
      @salida.values
    end

    # TODO: a default mju.
    def train(target, mju)
      @salida.train(target, mju)
      self
    end

    def pair(input, target, mju) = set(input).update.train(target, mju)

    def pairs(pairs, mju)
      pairs.shuffle.each { |input, target| pair(input, target, mju) }
      return self unless block_given?

      pairs.shuffle.each { |i, t| pair(i, t, mju) } while yield
      self
    end

    def inspect = map(&:inspect).join("\n")

    def to_s = map(&:to_s).join("\n")
  end
end
