# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Summa is a network which has each yin neuron sum two "corresponding" neurons
  # above(entrada). See code for "corresponding" semantic.
  module Summa
    def self.bless(myself)
      myself.yin.synthesis
      myself.extend Summa
      myself
    end

    def inspect
      "#Summa #{super}"
    end
  end
end
