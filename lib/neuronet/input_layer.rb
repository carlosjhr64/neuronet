# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Neuronet::InputLayer is an Array of Neuronet::Node's.
  # It can be used for the input layer of a feed forward network.
  class InputLayer < Array
    # number of nodes
    def initialize(length, inputs = [])
      super(length)
      0.upto(length - 1) { self[_1] = Neuronet::Node.new inputs[_1].to_f }
    end

    # This is where one enters the "real world" inputs.
    def set(inputs)
      0.upto(length - 1) { |index| self[index].value = inputs[index].to_f }
      self
    end

    def values
      map(&:value)
    end

    def inspect
      map(&:inspect).join(',')
    end

    def to_s
      map(&:to_s).join(',')
    end
  end
end
