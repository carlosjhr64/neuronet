# frozen_string_literal: true

module Neuronet
  # Trainable adds error backpropagation and training.
  module Trainable
    # Backpropagates errors through output layer.
    def backpropagate(errors)
      output_layer.each_with_index do |neuron, i|
        neuron.backpropagate(errors[i])
      end
    end

    # Single training step: forward, error, backprop.
    # Scales error by 1/nju (sensitivity).
    def train(inputs, targets, nju)
      actuals = self * inputs
      errors = targets.zip(actuals)
                      .map { |target, actual| (target - actual) / nju }
      backpropagate(errors)
    end

    # Trains on shuffled input-target pairs.
    def pairs(pairs, nju)
      pairs.shuffle.each { |inputs, targets| train(inputs, targets, nju) }
    end
  end
end
