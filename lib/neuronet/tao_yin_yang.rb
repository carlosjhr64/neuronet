# frozen_string_literal: true

# Neuronet module
module Neuronet
  # The obvious TaoYinYang ScaledNetwork
  module TaoYinYang
    def self.[](size)
      Tao.bless Yin.bless Yang.bless ScaledNetwork.new [size, size, size]
    end
  end
end
