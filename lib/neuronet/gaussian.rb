# frozen_string_literal: true

# Neuronet module
module Neuronet
  # "Normal Distribution"
  # Gaussian sub-classes Scale and is used exactly the same way. The only
  # changes are that it calculates the arithmetic mean (average) for center and
  # the standard deviation for spread.
  # :reek:DuplicateMethodCall inputs.length(twice) is an attribute
  # :reek:UncommunicativeVariableName sum2
  # :reek:InstanceVariableAssumption @center @spread
  class Gaussian < Scale
    # :reek:TooManyStatements
    def set(inputs)
      @center ||= inputs.sum.to_f / inputs.length
      unless @spread
        sum2 = inputs.map { @center - it }.sum { it * it }.to_f
        @spread = Math.sqrt(sum2 / (inputs.length - 1.0))
      end
      self
    end
  end
end
