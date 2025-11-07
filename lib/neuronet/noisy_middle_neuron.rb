# frozen_string_literal: true

module Neuronet
  # Middle Neuron
  class NoisyMiddleNeuron < MiddleNeuron
    include NoisyBackpropagate
  end
end
