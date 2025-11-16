# frozen_string_literal: true

module Neuronet
  # Trainable adds error backpropagation and training.
  module Trainable
    def pairs(pairs, nju: expected_nju)
      pairs.shuffle.each { |inputs, targets| train(inputs, targets, nju:) }
    end

    def train(inputs, targets, nju:)
      actuals = self * inputs
      errors = targets.zip(actuals).map { |target, actual| target - actual }
      error, index = pivot(errors)
      neuron = output_layer[index]
      neuron.backpropagate!(error / nju)
    end

    def pivot(errors)
      error = index = 0.0
      errors.each_with_index do |e, i|
        next unless e.abs > error.abs

        error = e
        index = i
      end
      [error, index]
    end

    def sum_of_squared_errors(pairs)
      pairs.sum do |inputs, targets|
        actuals = self * inputs
        targets.zip(actuals).sum { |t, a| (e = t - a) * e }
      end
    end
  end
end
