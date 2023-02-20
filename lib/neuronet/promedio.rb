# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Promedio is a network which has each yin neuron sum three neurons "directly"
  # above(entrada). See code for "directly" semantic.
  module Promedio
    def self.bless(myself)
      yin = myself.yin
      # just cover as much as you can
      in_length = [myself.entrada.length, yin.length].min
      0.upto(in_length - 1) do |index|
        neuron = yin[index]
        neuron.bias = Neuronet.bzero
        (-1..1).each do |i|
          connection = neuron.connections[index + i]
          connection.weight = Neuronet.wone / 3.0 if connection
        end
      end
      myself.extend Promedio
      myself
    end

    def inspect
      "#Promedio #{super}"
    end
  end
end
