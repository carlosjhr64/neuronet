# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious NeoYinYang ScaledNetwork
  module NeoYinYang
    def self.bless(myself)
      Neo.bless Yin.bless Yang.bless myself
    end

    def self.[](size)
      Neo.bless Yin.bless Yang.bless ScaledNetwork.new [size, size, size, size]
    end
  end
end
