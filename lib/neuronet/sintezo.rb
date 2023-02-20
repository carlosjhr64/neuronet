# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Sintezo is a network which has each @yang neuron sum two "corresponding"
  # neurons above(ambiguous layer). See code for "corresponding" semantic.
  module Sintezo
    def self.bless(myself)
      yang = myself.yang
      # just cover as much as you can
      in_length = [myself[-3].length / 2, yang.length].min
      0.upto(in_length - 1) do |index|
        neuron = yang[index]
        neuron.bias = Neuronet.bzero
        neuron.connections[2 * index].weight = Neuronet.wone / 2.0
        neuron.connections[(2 * index) + 1].weight = Neuronet.wone / 2.0
      end
      myself.extend Sintezo
      myself
    end

    def inspect
      "#Sintezo #{super}"
    end
  end
end
