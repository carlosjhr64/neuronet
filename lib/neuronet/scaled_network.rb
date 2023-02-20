# frozen_string_literal: true

# Neuronet module
module Neuronet
  # ScaledNetwork is a subclass of FeedForwardNetwork.
  # It automatically scales the problem given to it
  # by using a Scale type instance set in @distribution.
  # The attribute, @distribution, is set to Neuronet::Gaussian.new by default,
  # but one can change this to Scale, LogNormal, or one's own custom mapper.
  class ScaledNetwork < FeedForward
    attr_accessor :distribution, :reset

    def initialize(layers, distribution: Gaussian.new, reset: false)
      super(layers)
      @distribution = distribution
      @reset        = reset
    end

    # ScaledNetwork set works just like FeedForwardNetwork's set method,
    # but calls @distribution.set(values) first if @reset is true.
    # Sometimes you'll want to set the distribution with the entire data set,
    # and then there will be times you'll want to reset the distribution
    # with each input.
    def set(input)
      @distribution.reset(input) if @reset
      super(@distribution.mapped_input(input))
    end

    def input
      @distribution.unmapped_input(super)
    end

    def output
      @distribution.unmapped_output(super)
    end

    def *(_other)
      @distribution.unmapped_output(super)
    end

    def train(target)
      super(@distribution.mapped_output(target))
    end

    def inspect
      distribution = @distribution.class.to_s.split(':').last
      "#distribution:#{distribution} #reset:#{@reset} " + super
    end
  end
end
