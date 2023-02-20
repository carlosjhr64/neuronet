# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Mediocris is a network which has each @yang neuron sum three neurons
  # "directly" above(ambiguous layer). See code for "directly" semantic.
  module Mediocris
    def self.bless(myself)
      yang = myself.yang
      # just cover as much as you can
      in_length = [myself[-3].length, yang.length].min
      0.upto(in_length - 1) do |index|
        neuron = yang[index]
        neuron.bias = Neuronet.bzero
        (-1..1).each do |i|
          connection = neuron.connections[index + i]
          connection.weight = Neuronet.wone / 3.0 if connection
        end
      end
      myself.extend Mediocris
      myself
    end

    def inspect
      "Mediocris #{super}"
    end
  end
end
