# frozen_string_literal: true

# Neuronet module / Constants
# :reek:TooManyConstants and :reek:Attribute
module Neuronet
  # Neuronet allows one to set the format to use for displaying float values,
  # mostly used in the inspect methods.
  # [Docs](https://docs.ruby-lang.org/en/master/format_specifications_rdoc.html)
  FORMAT = '%.13g'

  # An artificial neural network uses a squash function to determine the
  # activation value of a neuron.  The squash function for Neuronet is the
  # [Sigmoid function](http://en.wikipedia.org/wiki/Sigmoid_function) which sets
  # the neuron's activation value between 0.0 and 1.0.  This activation value is
  # often thought of on/off or true/false.  For classification problems,
  # activation values near one are considered true while activation values near
  # 0.0 are considered false.  In Neuronet I make a distinction between the
  # neuron's activation value and it's representation to the problem.  This
  # attribute, activation, need never appear in an implementation of Neuronet,
  # but it is mapped back to it's unsquashed value every time the implementation
  # asks for the neuron's value.  One should scale the problem with most data
  # points between -1 and 1, extremes under 2s, and no outbounds above 3s.
  # Standard deviations from the mean is probably a good way to figure the scale
  # of the problem.
  SQUASH     = ->(unsquashed) { 1.0 / (1.0 + Math.exp(-unsquashed)) }
  UNSQUASH   = ->(squashed) { Math.log(squashed / (1.0 - squashed)) }
  DERIVATIVE = ->(squash) { squash * (1.0 - squash) }

  # I'll want to have a neuron roughly mirror another later.   Let [v] be the
  # squash of v.  Consider:
  #   v = b + w*[v]
  # There is no constant b and w that will satisfy the above equation for all v.
  # But one can satisfy the equation for v in {-1, 0, 1}.  Find b and w such
  # that:
  #   A: 0 = b + w*[0]
  #   B: 1 = b + w*[1]
  #   C: -1 = b + w*[-1]
  # Use A and B to solve for b and w:
  #   A: 0 = b + w*[0]
  #      b = -w*[0]
  #   B: 1 = b + w*[1]
  #      1 = -w*[0] + w*[1]
  #      1 = w*(-[0] + [1])
  #      w = 1/([1] - [0])
  #      b = -[0]/([1] - [0])
  # Verify A, B, and C:
  #   A: 0 = b + w*[0]
  #      0 = -[0]/([1] - [0]) + [0]/([1] - [0])
  #      0 = 0 # OK
  #   B: 1 = b + w*[1]
  #      1 = -[0]/([1] - [0]) + [1]/([1] - [0])
  #      1 = ([1] - [0])/([1] - [0])
  #      1 = 1 # OK
  # Using the squash function identity, [v] = 1 - [-v]:
  #   C: -1 = b + w*[-1]
  #      -1 = -[0]/([1] - [0]) + [-1]/([1] - [0])
  #      -1 = ([-1] - [0])/([1] - [0])
  #      [0] - [1] = [-1] - [0]
  #      [0] - [1] = 1 - [1] - [0] # Identity substitution.
  #      [0] = 1 - [0] # OK, by identity(0=-0).
  # Evaluate given that [0] = 0.5:
  #      b = -[0]/([1] - [0])
  #      b = [0]/([0] - [1])
  #      b = 0.5/(0.5 - [1])
  #      w = 1/([1] - [0])
  #      w = 1/([1] - 0.5)
  #      w = -2 * 0.5/(0.5 - [1])
  #      w = -2 * b
  BZERO = 0.5 / (0.5 - SQUASH[1.0])
  WONE  = -2.0 * BZERO

  # Although the implementation is free to set all parameters for each neuron,
  # Neuronet by default creates zeroed neurons.  Association between inputs and
  # outputs are trained, and neurons differentiate from each other randomly.
  # Differentiation among neurons is achieved by noise in the back-propagation
  # of errors.  This noise is provided by rand + rand.  I chose rand + rand to
  # give the noise an average value of one and a bell shape distribution.
  NOISE = ->(error) { error * (rand + rand) }

  # One may choose not to have noise.
  NO_NOISE = ->(error) { error }

  # To keep components bounded, Neuronet limits the weights, biases, and values.
  # Note that on a 64-bit machine SQUASH[37] rounds to 1.0, and
  # SQUASH[9] is 0.99987...
  MAXW = 9.0  # Maximum weight
  MAXB = 18.0 # Maximum bias
  MAXV = 36.0 # Maximum value

  # Mu learning factor.
  LEARNING = 1.0

  # The above constants are the defaults for Neuronet.  They are set below in
  # accessable module attributes.  The user may change these to suit their
  # needs.
  class << self
    attr_accessor :format, :squash, :unsquash, :derivative, :bzero, :wone,
                  :noise, :maxw, :maxb, :maxv, :learning
  end
  self.squash     = SQUASH
  self.unsquash   = UNSQUASH
  self.derivative = DERIVATIVE
  self.bzero      = BZERO
  self.wone       = WONE
  self.noise      = NOISE
  self.format     = FORMAT
  self.maxw       = MAXW
  self.maxb       = MAXB
  self.maxv       = MAXV
  self.learning   = LEARNING
end
