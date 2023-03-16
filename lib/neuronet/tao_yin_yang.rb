# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious TaoYinYang ScaledNetwork
  module TaoYinYang
    def self.[](size)
      TaoYinYang.bless ScaledNetwork.new [size, size, size]
    end

    def self.bless(myself)
      Tao.bless Yin.bless Yang.bless myself
    end
  end
end
