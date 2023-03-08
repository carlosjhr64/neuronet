# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Synthesis is a network which has each @salida neuron sum two "corresponding"
  # neurons above(yang). See code for "corresponding" semantic.
  module Synthesis
    def self.bless(myself)
      myself.salida.synthesis
      myself.extend Synthesis
      myself
    end

    def inspect
      "#Synthesis #{super}"
    end
  end
end
