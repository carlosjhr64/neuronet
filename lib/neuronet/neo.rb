# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Neo is a network which has its @yang layer initially mirroring @yin.
  module Neo
    # Neo.bless sets the bias of each @yang[i] to bzero, and
    # the weight of pairing (@yang[i], @yin[i]) connections to wone.
    # This makes @yang initially mirror @yin.
    def self.bless(myself)
      yang = myself.yang
      # just mirror as much of myself.yang as you can
      yin_length = [myself.yin.length, yang.length].min
      # connections from yang[i] to yin[i] are wone... mirroring to start.
      0.upto(yin_length - 1) do |index|
        node = yang[index]
        node.connections[index].weight = Neuronet.wone
        node.bias = Neuronet.bzero
      end
      myself.extend Neo
      myself
    end

    def inspect
      "#Neo #{super}"
    end
  end
end
