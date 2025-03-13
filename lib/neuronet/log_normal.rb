# frozen_string_literal: true

# Neuronet module
module Neuronet
  # "Log-Normal Distribution"
  # LogNormal sub-classes Gaussian to transform the values to a logarithmic
  # scale.
  class LogNormal < Gaussian
    def set(inputs)
      super(inputs.map { |value| Math.log(value) })
    end

    def mapped(inputs)
      super(inputs.map { |value| Math.log(value) })
    end

    def unmapped(outputs)
      super.map { |value| Math.exp(value) }
    end
  end
end
