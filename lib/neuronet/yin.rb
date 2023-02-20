# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Yin is a network which has its @yin layer initially mirroring @entrada.
  module Yin
    # Yin.bless sets the bias of each @yin[i] to bzero, and
    # the weight of pairing (@yin[i], @entrada[i]) connections to wone.
    # This makes @yin initially mirror @entrada.
    def self.bless(myself)
      yin = myself.yin
      # just mirror as much of myself.entrada as you can
      in_length = [myself.entrada.length, yin.length].min
      # connections from yin[i] to entrada[i] are wone... mirroring to start.
      0.upto(in_length - 1) do |index|
        node = yin[index]
        node.connections[index].weight = Neuronet.wone
        node.bias = Neuronet.bzero
      end
      myself.extend Yin
      myself
    end

    def inspect
      "#Yin #{super}"
    end
  end
end
