# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious YinYang ScaledNetwork
  module YinYang
    def self.bless(myself)
      Yin.bless Yang.bless myself
    end

    def self.[](size)
      Yin.bless Yang.bless ScaledNetwork.new [size, size, size]
    end
  end
end
