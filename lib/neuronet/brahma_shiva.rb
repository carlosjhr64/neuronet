# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious BrahmaShiva ScaledNetwork
  module BrahmaShiva
    def self.[](size)
      BrahmaShiva.bless ScaledNetwork.new [size, 2 * size, size]
    end

    def self.bless(myself)
      Brahma.bless Shiva.bless myself
    end
  end
end
