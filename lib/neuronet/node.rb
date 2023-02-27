# frozen_string_literal: true

# Neuronet module / Node class
module Neuronet
  # In Neuronet, there are two main types of objects:  Nodes and Connections.
  # A Node has a value which the implementation can set.  A plain Node instance
  # is used primarily as input neurons, and its value is not changed by
  # training.  It is a terminal for backpropagation of errors.  Nodes are used
  # for the input layer.
  class Node
    # For bookkeeping, each Node is given a label, starting with 'a' by default.
    class << self; attr_accessor :label; end
    Node.label = 'a'

    attr_reader :activation, :label

    # A (input)Node is constant.  The methods update and partial asks the node
    # to reevaluate and return its activation value.  Since the input node does
    # not change, it simply returns its current activation value.  But these
    # will be over-ridden by the Neuron class.
    alias update activation
    alias partial activation

    # The "real world" value of a node is the value of it's activation
    # unsquashed.  So, set the activation to the squashed real world value.
    def value=(value)
      # If value is out of bounds, set it to the bound.
      if value.abs > Neuronet.maxv
        value = value.positive? ? Neuronet.maxv : -Neuronet.maxv
      end
      @activation = Neuronet.squash[value]
    end

    # By default, a Node's value is initialized to zero.
    def initialize(value = Neuronet.vzero)
      self.value = value
      @label = Node.label
      Node.label = Node.label.next
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

    # A node inspects itself as "label:value".
    def inspect
      "#{@label}:#{Neuronet.format % value}"
    end

    # A node plainly puts itself as "label".
    def to_s
      @label
    end
  end
end
