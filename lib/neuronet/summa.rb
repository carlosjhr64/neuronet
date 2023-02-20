# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Summa is a network which has each yin neuron sum two "corresponding" neurons
  # above(entrada). See code for "corresponding" semantic.
  module Summa
    def self.bless(myself)
      yin = myself.yin
      # just cover as much as you can
      in_length = [myself.entrada.length / 2, yin.length].min
      0.upto(in_length - 1) do |index|
        neuron = yin[index]
        neuron.bias = Neuronet.bzero
        neuron.connections[2 * index].weight = Neuronet.wone / 2.0
        neuron.connections[(2 * index) + 1].weight = Neuronet.wone / 2.0
      end
      myself.extend Summa
      myself
    end

    def inspect
      "#Summa #{super}"
    end
  end
end
