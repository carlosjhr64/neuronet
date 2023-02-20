# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Vishnu is a network which has its @yang layer initially mirror
  # and "shadow" @yin.
  module Vishnu
    # Vishnu.bless sets the weights of pairing even yang (@yang[2*i], @yin[i])
    # connections to wone, and pairing odd yang (@yang[2*i+1], @yin[i])
    # connections to negative wone. Likewise the bias with bzero.
    # This makes @yang initially mirror and shadow @yin.
    # The pairing is done starting with (@yang[0], @yin[0]).
    # That is, starting with (@yang.first, @yin.first).
    def self.bless(myself)
      yang = myself.yang
      # just cover as much as you can
      yin_length = [myself.yin.length, yang.length / 2].min
      # connections from yang[2*i] to yin[i] are wone... mirroring to start.
      # connections from yang[2*i+1] to yin[i] are -wone... shadowing to start.
      0.upto(yin_length - 1) do |index|
        even = yang[2 * index]
        odd = yang[(2 * index) + 1]
        even.connections[index].weight = Neuronet.wone
        even.bias = Neuronet.bzero
        odd.connections[index].weight = -Neuronet.wone
        odd.bias = -Neuronet.bzero
      end
      myself.extend Vishnu
      myself
    end

    def inspect
      "#Vishnu #{super}"
    end
  end
end
