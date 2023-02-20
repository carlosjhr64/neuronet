# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Yang is a network which has its @salida layer initially mirroring @yang.
  module Yang
    # Yang.bless sets the bias of each @salida[i] to bzero, and
    # the weight of pairing (@salida[i], @yang[i]) connections to wone.
    # This makes @salida initially mirror @yang.
    def self.bless(myself)
      salida = myself.salida
      # just mirror as much of myself.yang as you can
      yang_length = [myself.yang.length, salida.length].min
      # connections from salida[i] to yang[i] are wone... mirroring to start.
      0.upto(yang_length - 1) do |index|
        node = salida[index]
        node.connections[index].weight = Neuronet.wone
        node.bias = Neuronet.bzero
      end
      myself.extend Yang
      myself
    end

    def inspect
      "#Yang #{super}"
    end
  end
end
