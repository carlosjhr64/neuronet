# frozen_string_literal: true

# Neuronet module
module Neuronet
  # In Neuronet, there are two main types of objects: Nodes and Connections.
  # A Node has a value which the implementation can set.
  # A plain Node instance is used primarily as input neurons, and
  # its value is not changed by training.
  # It is a terminal for backpropagation of errors.
  # Nodes are used for the input layer.
  class Node
    class << self
      attr_accessor :label
    end

    Node.label = 'a'

    attr_reader :activation, :label
    # A Node is constant (Input)
    alias update activation
    alias partial activation

    # The "real world" value of a node is the value of it's activation
    # unsquashed. So, set the activation to the squashed real world value.
    def value=(value)
      if value.abs > Neuronet.maxv
        value = value.positive? ? Neuronet.maxv : -Neuronet.maxv
      end
      @activation = Neuronet.squash[value]
    end

    def initialize(value = 0.0)
      self.value = value
      @label = Node.label and Node.label = Node.label.succ
    end

    # The "real world" value is stored as a squashed activation.
    # So for value, return the unsquashed activation.
    def value
      Neuronet.unsquash[@activation]
    end

    # Node is a terminal where backpropagation ends.
    def backpropagate(_error)
      # to be over-ridden
      self
    end

    def inspect
      "#{@label}:#{Neuronet.format % value}"
    end

    def to_s
      @label
    end
  end
end
