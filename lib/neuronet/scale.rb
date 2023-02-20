# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Neuronet::Scale is a class to help scale problems to fit within a network's
  # "field of view". Given a list of values, it finds the minimum and maximum
  # values and establishes a mapping to a scaled set of numbers between minus
  # one and one (-1,1).
  class Scale
    attr_accessor :spread, :center

    # If the value of center is provided, then
    # that value will be used instead of
    # calculating it from the values passed to method #set.
    # Likewise, if spread is provided, that value of spread will be used.
    def initialize(factor: 1.0, center: nil, spread: nil)
      @factor = factor
      @center = center
      @spread = spread
    end

    def set(inputs)
      min, max = inputs.minmax
      @center ||= (max + min) / 2.0
      @spread ||= (max - min) / 2.0
      self
    end

    def reset(inputs)
      @center = @spread = nil
      set(inputs)
    end

    def mapped(inputs)
      factor = 1.0 / (@factor * @spread)
      inputs.map { |value| factor * (value - @center) }
    end
    alias mapped_input mapped
    alias mapped_output mapped

    # Note that it could also unmap inputs, but
    # outputs is typically what's being transformed back.
    def unmapped(outputs)
      factor = @factor * @spread
      outputs.map { |value| (factor * value) + @center }
    end
    alias unmapped_input unmapped
    alias unmapped_output unmapped
  end
end
