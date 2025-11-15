# frozen_string_literal: true

module Neuronet
  # Backpropagate provides simple, clamp-limited weight/bias updates.
  module Backpropagate
    # Back-propagates errors, updating bias and connection weights.
    # Clamps updates to [-max, +max].
    # Recursively calls on connected neurons.
    def backpropagate(error)
      return if @backpropagated

      @backpropagated = true
      update_bias(error)
      update_connections(error)
    end

    def update_bias(error)
      bmax = Config.bias_clamp
      self.bias = add(bias, error).clamp(-bmax, bmax)
    end

    def add(bias, error) = bias + error

    def update_connections(error)
      wmax = Config.weight_clamp
      connections.each do |c|
        n = c.neuron
        w = c.weight + multiply(n.activation, error)
        c.weight = w.clamp(-wmax, wmax)
        n.backpropagate(error)
      end
    end

    def multiply(activation, error) = activation * error

    def reset_backpropagated!
      return unless @backpropagated

      @backpropagated = false
      connections.each { |c| c.neuron.reset_backpropagated! }
    end

    def backpropagate!(error)
      reset_backpropagated!
      backpropagate(error)
    end
  end
end
