# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Sintezo is a network which has each @yang neuron sum two "corresponding"
  # neurons above(ambiguous layer). See code for "corresponding" semantic.
  module Sintezo
    def self.bless(myself)
      myself.yang.synthesis
      myself.extend Sintezo
      myself
    end

    def inspect
      "#Sintezo #{super}"
    end
  end
end
