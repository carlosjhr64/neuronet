# frozen_string_literal: true

module Neuronet
  # FeedForward is a fully connected neural network with >= 3 layers.
  class FeedForward
    # [NetwordStats](network_stats.rb)
    include NetworkStats
    # [Exportable](exportable.rb)
    include Exportable
    # [Trainable](trainable.rb)
    include Trainable
    # [Arrayble](arrayable.rb)
    include Arrayable

    # Example:
    #     ff = Neuronet::FeedForward.new(4, 8, 4)
    def initialize(*sizes, full_neuron: Neuron)
      length = sizes.length
      raise 'Need at least 3 layers' if length < 3

      @layers = Array.new(length) { Layer.new(sizes[it], full_neuron:) }
      1.upto(length - 1) { @layers[it].connect(@layers[it - 1]) }
      @input_layer = @layers[0]
      @output_layer = @layers[-1]
      @hidden_layers = @layers[1...-1]
    end

    attr_reader :input_layer, :hidden_layers, :output_layer

    # Sets the input values
    def set(values)
      @input_layer.set(values)
    end

    # Updates hidden layers (input assumed set).
    def update
      @hidden_layers.each(&:update)
    end

    # Gets output
    def values
      @output_layer.values
    end

    # Forward pass: set input, update, return output.
    def *(other)
      set(other)
      update
      values
    end

    def to_a = @layers
  end
end
