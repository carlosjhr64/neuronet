# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious NeoYinYang ScaledNetwork
  module NeoYinYang
    def self.[](size)
      NeoYinYang.bless ScaledNetwork.new [size, size, size, size]
    end

    def self.bless(myself)
      Neo.bless Yin.bless Yang.bless myself
    end
  end
end
