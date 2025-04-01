# frozen_string_literal: true

# Neuronet module / FeedForward class
module Neuronet
  # A Feed Forward Network
  # TODO: :reek:SubclassedFromCoreClass
  # TODO: :reek:InstanceVariableAssumption @expected_mju
  class FeedForward < Array
    # Example:
    #   ff = Neuronet::FeedForward.new([2, 3, 1])
    def initialize(layers)
      length = layers.length
      raise 'Need at least 2 layers' if length < 2

      super(length) { Layer.new(layers[it]) }
      1.upto(length - 1) { self[it].connect(self[it - 1]) }
    end

    # Set the input layer.
    def set(input)
      first.set(input)
      self
    end

    def input = first.values

    # Update the network.
    def update
      # update up the layers
      1.upto(length - 1) { self[it].partial }
      self
    end

    def output = last.values

    # Consider:
    #   m = Neuronet::FeedForward.new(layers)
    # Want:
    #   output = m * input
    def *(other)
      set(other)
      update
      last.values
    end

    # 𝝁 + 𝜧 𝝁' + 𝜧 𝜧'𝝁" + 𝜧 𝜧'𝜧"𝝁"' + ...
    # |𝜧| ~ |𝑾||𝓑𝒂|
    # |∑𝑾| ~ √𝑁
    # |𝓑𝒂| ~ ¼
    # |𝝁| ~ 1+∑|𝒂'| ~ 1+½𝑁
    # :reek:DuplicateMethodCall layer.length(twice) is an attribute
    # :reek:TooManyStatements
    def expected_mju!
      sum = 0.0
      mju = 1.0
      reverse[1..].each do |layer|
        sum += mju * (1.0 + (0.5 * layer.length))
        mju *= 0.25 * Math.sqrt(layer.length)
      end
      @expected_mju = Neuronet.learning * sum
    end

    def expected_mju
      @expected_mju || expected_mju!
    end

    def average_mju
      last.average_mju
    end

    def train(target, mju = expected_mju)
      last.train(target, mju)
      self
    end

    def pair(input, target, mju = expected_mju)
      set(input).update.train(target, mju)
    end

    # :reek:DuplicateMethodCall shuffle(twice) re-shuffles!
    # :reek:UncommunicativeVariableName
    # :reek:TooManyStatements
    def pairs(pairs, mju = expected_mju)
      pairs.shuffle.each { |input, target| pair(input, target, mju) }
      return self unless block_given?

      pairs.shuffle.each { |i, t| pair(i, t, mju) } while yield
      self
    end

    def inspect = map(&:inspect).join("\n")

    def to_s = map(&:to_s).join("\n")
  end
end
