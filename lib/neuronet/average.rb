# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Average is a network which has each @salida neuron sum three neurons
  # "directly" above(yang). See code for "directly" semantic.
  module Average
    def self.bless(myself)
      salida = myself.salida
      # just cover as much as you can
      in_length = [myself.yang.length, salida.length].min
      0.upto(in_length - 1) do |index|
        neuron = salida[index]
        neuron.bias = Neuronet.bzero
        neuron.bias = Neuronet.bzero
        (-1..1).each do |i|
          connection = neuron.connections[index + i]
          connection.weight = Neuronet.wone / 3.0 if connection
        end
      end
      myself.extend Average
      myself
    end

    def inspect
      "Average #{super}"
    end
  end
end
