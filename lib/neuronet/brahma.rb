# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Brahma is a network which has its @yin layer initially mirror and
  # "shadow" @entrada.
  module Brahma
    # Brahma.bless sets the weights of pairing even yin (@yin[2*i], @entrada[i])
    # connections to wone, and pairing odd yin (@yin[2*i+1], @entrada[i])
    # connections to negative wone. Likewise the bias with bzero.
    # This makes @yin initially mirror and shadow @entrada. The pairing is done
    # starting with (@yin[0], @entrada[0]).
    # That is, starting with (@yin.first, @entrada.first).
    def self.bless(myself)
      yin = myself.yin
      # just cover as much as you can
      in_length = [myself.entrada.length, yin.length / 2].min
      # connections from yin[2*i] to entrada[i] are wone, mirroring to start.
      # connections from yin[2*i+1] to entrada[i] are -wone, shadowing to start.
      0.upto(in_length - 1) do |index|
        even = yin[2 * index]
        odd = yin[(2 * index) + 1]
        even.connections[index].weight = Neuronet.wone
        even.bias = Neuronet.bzero
        odd.connections[index].weight = -Neuronet.wone
        odd.bias = -Neuronet.bzero
      end
      myself.extend Brahma
      myself
    end

    def inspect
      "#Brahma #{super}"
    end
  end
end
