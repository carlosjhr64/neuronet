# frozen_string_literal: true

# Neuronet module
module Neuronet
  FORMAT = '%.14g'

  # An artificial neural network uses a squash function to determine the
  # activation value of a neuron. The squash function for Neuronet is the
  # [Sigmoid function](http://en.wikipedia.org/wiki/Sigmoid_function)
  # which sets the neuron's activation value between 1.0 and 0.0. This
  # activation value is often thought of on/off or true/false. For
  # classification problems, activation values near one are considered true
  # while activation values near 0.0 are considered false. In Neuronet I make a
  # distinction between the neuron's activation value and it's representation to
  # the problem. This attribute, activation, need never appear in an
  # implementation of Neuronet, but it is mapped back to it's unsquashed value
  # every time the implementation asks for the neuron's value. One should scale
  # the problem with most data points between -1 and 1, extremes under 2s, and
  # no outbounds above 3s. Standard deviations from the mean is probably a good
  # way to figure the scale of the problem.
  SQUASH = lambda do |unsquashed|
    1.0 / (1.0 + Math.exp(-unsquashed))
  end
  UNSQUASH = lambda do |squashed|
    Math.log(squashed / (1.0 - squashed))
  end

  # I'll want to have a neuron mirror a node later.
  # I derive BZERO and WONE in README.md, but
  # the point here is that values -1, 0, and 1 map back to themselves:
  #   BZERO + WONE*SQUASH[-1.0] #=> -1.0
  #   BZERO + WONE*SQUASH[0.0]  #=> 0.0
  #   BZERO + WONE*SQUASH[1.0]  #=> 1.0
  BZERO = 1.0 / (1.0 - (2.0 * SQUASH[1.0]))
  WONE  = -2.0 * BZERO

  # Although the implementation is free to set all parameters for each neuron,
  # Neuronet by default creates zeroed neurons. Association between inputs and
  # outputs are trained, and neurons differentiate from each other randomly.
  # Differentiation among neurons is achieved by noise in the back-propagation
  # of errors. This noise is provided by rand + rand. I chose rand + rand to
  # give the noise an average value of one and a bell shape distribution.
  NOISE = ->(error) { error * (rand + rand) }

  # One may choose not to have noise.
  NO_NOISE = IDENTITY = ->(error) { error }

  class << self
    attr_accessor :squash, :unsquash, :bzero, :wone, :noise, :format
  end
  self.squash   = SQUASH
  self.unsquash = UNSQUASH
  self.bzero    = BZERO
  self.wone     = WONE
  self.noise    = NOISE
  self.format   = FORMAT

  class << self; attr_accessor :maxw, :maxb, :maxv; end
  self.maxw     = 9.0
  self.maxb     = 18.0
  self.maxv     = 36.0
end
