# frozen_string_literal: true

module Neuronet
  # Middle Neuron
  class NoisyNeuron < Neuron
    include NoisyBackpropagate
  end
end
