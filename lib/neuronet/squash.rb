# frozen_string_literal: true

module Neuronet
  # Squash provides logistic sigmoid function.
  module Squash
    # Logistic sigmoid: maps Real to (0, 1).
    def squash(value) = 1.0 / (1.0 + Math.exp(-value))
    # Inverse sigmoid: maps (0, 1) to Real.
    def unsquash(activation) = Math.log(activation / (1.0 - activation))
    module_function :squash, :unsquash
  end
end
