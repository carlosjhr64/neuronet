# frozen_string_literal: true

module Neuronet
  # Maximum values for biases and weights
  module Clamp
    class << self; attr_accessor :bias, :weight; end
    self.bias   = 18.0
    self.weight = 9.0
  end
end
