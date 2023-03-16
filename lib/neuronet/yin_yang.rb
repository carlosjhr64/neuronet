# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious YinYang ScaledNetwork
  module YinYang
    def self.[](size)
      YinYang.bless ScaledNetwork.new [size, size, size]
    end

    def self.bless(myself)
      Yin.bless Yang.bless myself
    end
  end
end
