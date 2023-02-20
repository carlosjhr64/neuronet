# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Synthesis is a network which has each @salida neuron sum two "corresponding"
  # neurons above(yang). See code for "corresponding" semantic.
  module Synthesis
    def self.bless(myself)
      salida = myself.salida
      # just cover as much as you can
      in_length = [myself.yang.length / 2, salida.length].min
      0.upto(in_length - 1) do |index|
        neuron = salida[index]
        neuron.bias = Neuronet.bzero
        neuron.connections[2 * index].weight = Neuronet.wone / 2.0
        neuron.connections[(2 * index) + 1].weight = Neuronet.wone / 2.0
      end
      myself.extend Synthesis
      myself
    end

    def inspect
      "#Synthesis #{super}"
    end
  end
end
