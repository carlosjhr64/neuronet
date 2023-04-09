# frozen_string_literal: true

# Neuronet is a neural network library for Ruby.
module Neuronet
  VERSION = '7.0.230409'
  require_relative           'neuronet/constants'
  autoload :Connection,      'neuronet/connection'
  autoload :Neuron,          'neuronet/neuron'
  autoload :Layer,           'neuronet/layer'
  autoload :FeedForward,     'neuronet/feed_forward'
  autoload :Scale,           'neuronet/scale'
  autoload :Gaussian,        'neuronet/gaussian'
  autoload :LogNormal,       'neuronet/log_normal'
  autoload :ScaledNetwork,   'neuronet/scaled_network'
end
