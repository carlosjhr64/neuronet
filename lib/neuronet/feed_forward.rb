# frozen_string_literal: true

# Neuronet module / FeedForward class
module Neuronet
  # A Feed Forward Network
  class FeedForward < Array
    attr_reader :entrada, :salida, :yin, :yang

    # FeedForward's mu sums the mu of all layers and is used to reduce the
    # back-propagated error.
    def mu = Neuronet.learning * sum(Neuronet.zero, &:mu)

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

    def input
      @entrada.values
    end

    # Update the network.
    def update
      # update up the layers
      1.upto(length - 1) { self[_1].partial }
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

    def train(target, mju = mu)
      @salida.train(target, mju)
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
      map(&:inspect).join("\n")
    end

    def to_s
      map(&:to_s).join("\n")
    end
  end
end
