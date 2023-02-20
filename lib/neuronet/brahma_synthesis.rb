# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious BrahmaSynthesis ScaledNetwork
  module BrahmaSynthesis
    def self.[](size)
      Brahma.bless Synthesis.bless ScaledNetwork.new [size, 2 * size, size]
    end
  end
end
