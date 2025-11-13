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
    # Expected nju is good for Perceptrons.
    # Consider setting nju to expected_nju * output_layer.size for an MLP.
    # See test/tc_backpropagate's test_ff_backpropagate to see
    # what the problem with Trainable#backpropagation is.
    def pairs(pairs, nju)
      pairs.shuffle.each { |inputs, targets| train(inputs, targets, nju) }
    end

    # This version of pairs tries to be smarter about training,
    # by back-propagating only the biggest error.
    # If nju estimate is provided, it'll iterate faster.
    def pairs_pivot(pairs, nju = nil)
      pairs.shuffle.each { |inputs, targets| train_pivot(inputs, targets, nju) }
    end

    def train_pivot(inputs, targets, nju = nil)
      actuals = self * inputs
      errors = targets.zip(actuals).map { |target, actual| target - actual }
      error, index = pivot(errors)
      neuron = output_layer[index]
      nju ||= Config.nju_mult * neuron.nju.abs
      neuron.backpropagate(error / nju)
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

    # This version avoids the deep back-propagation problem
    # by randomly picking one output neuron to update.
    def pairs_random(pairs, nju = nil)
      pairs.shuffle.each { |inputs, targets| train_random inputs, targets, nju }
    end

    # rubocop: disable Metrics
    def train_random(inputs, targets, nju = nil)
      actuals = self * inputs
      errors = targets.zip(actuals).map { |target, actual| target - actual }
      index = rand(errors.size)
      neuron = output_layer[index]
      nju ||= Config.nju_mult * neuron.nju.abs
      neuron.backpropagate(errors[index] / nju)
    end
    # rubocop: enable Metrics
  end
end
