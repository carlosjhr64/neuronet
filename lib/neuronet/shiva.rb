# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Shiva is a network which has its @salida layer initially mirror
  # and "shadow" @yang.
  module Shiva
    # Shiva.bless sets the weights of pairing even salida
    # (@salida[2*i], @yang[i]) connections to wone, and pairing odd
    # salida (@salida[2*i+1], @yang[i]) connections to negative wone.
    # Likewise the bias with bzero.
    # This makes @salida initially mirror and shadow @yang.
    # The pairing is done starting with (@salida[0], @yang[0]).
    # That is, starting with (@salida.first, @yang.first).
    def self.bless(myself)
      salida = myself.salida
      # just cover as much as you can
      yang_length = [myself.yang.length, salida.length / 2].min
      # connections from salida[2*i] to yang[i] are wone, mirroring to start.
      # connections from salida[2*i+1] to yang[i] are -wone, shadowing to start.
      0.upto(yang_length - 1) do |index|
        even = salida[2 * index]
        odd = salida[(2 * index) + 1]
        even.connections[index].weight = Neuronet.wone
        even.bias = Neuronet.bzero
        odd.connections[index].weight = -Neuronet.wone
        odd.bias = -Neuronet.bzero
      end
      myself.extend Shiva
      myself
    end

    def inspect
      "#Shiva #{super}"
    end
  end
end
