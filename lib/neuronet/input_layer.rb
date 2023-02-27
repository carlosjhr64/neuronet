# frozen_string_literal: true

# Neuronet module / InputLayer class
module Neuronet
  # Neuronet::InputLayer is an Array of Neuronet::Node's.
  # It can be used for the input layer of a feed forward network.
  class InputLayer < Array
    # length is number of nodes
    def initialize(length, zero: Neuronet.vzero, node: Neuronet::Node)
      super(length)
      0.upto(length - 1) { self[_1] = node.new(zero) }
    end

    # This is where one enters the "real world" inputs.
    def set(inputs, zero: Neuronet.vzero)
      0.upto(length - 1) { self[_1].value = inputs[_1] || zero }
      self
    end

    # Returns the real world values: [value,...]
    def values
      map(&:value)
    end

    # An InputLayer inspects itself as "label:value,...".
    def inspect
      map(&:inspect).join(',')
    end

    # An InputLayer puts itself as "label,...".
    def to_s
      map(&:to_s).join(',')
    end
  end
end
