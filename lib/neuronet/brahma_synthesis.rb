# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious BrahmaSynthesis ScaledNetwork
  module BrahmaSynthesis
    def self.[](size)
      BrahmaSynthesis.bless ScaledNetwork.new [size, 2 * size, size]
    end

    def self.bless(myself)
      Brahma.bless Synthesis.bless myself
    end
  end
end
