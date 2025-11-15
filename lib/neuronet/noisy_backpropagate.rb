# frozen_string_literal: true

module Neuronet
  # Noisy Backpropagate
  module NoisyBackpropagate
    include Backpropagate

    def add(bias, error) = bias + (error * (rand + rand))
    def multiply(activation, error) = activation * error * (rand + rand)
  end
end
