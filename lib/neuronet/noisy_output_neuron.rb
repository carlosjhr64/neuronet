# frozen_string_literal: true

module Neuronet
  # Middle Neuron
  class NoisyOutputNeuron < OutputNeuron
    include NoisyBackpropagate
  end
end
