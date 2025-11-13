# frozen_string_literal: true

module Neuronet
  # Maximum values for biases and weights
  module Config
    class << self; attr_accessor :bias_clamp, :weight_clamp, :nju_mult; end
    self.bias_clamp   = 18.0
    self.weight_clamp = 9.0
    self.nju_mult     = 2.0
  end
end
