# frozen_string_literal: true

# Neuronet is a neural network library for Ruby.
module Neuronet
  VERSION = '7.0.230319'
  require_relative           'neuronet/constants'
  autoload :Connection,      'neuronet/connection'
  autoload :Neuron,          'neuronet/neuron'
  autoload :Layer,           'neuronet/layer'
  autoload :FeedForward,     'neuronet/feed_forward'
  autoload :Scale,           'neuronet/scale'
  autoload :Gaussian,        'neuronet/gaussian'
  autoload :LogNormal,       'neuronet/log_normal'
  autoload :ScaledNetwork,   'neuronet/scaled_network'
  autoload :Tao,             'neuronet/tao'
  autoload :Yin,             'neuronet/yin'
  autoload :Yang,            'neuronet/yang'
  autoload :Neo,             'neuronet/neo'
  autoload :Brahma,          'neuronet/brahma'
  autoload :Vishnu,          'neuronet/vishnu'
  autoload :Shiva,           'neuronet/shiva'
  autoload :Summa,           'neuronet/summa'
  autoload :Sintezo,         'neuronet/sintezo'
  autoload :Synthesis,       'neuronet/synthesis'
  autoload :YinYang,         'neuronet/yin_yang'
  autoload :TaoYinYang,      'neuronet/tao_yin_yang'
  autoload :NeoYinYang,      'neuronet/neo_yin_yang'
  autoload :BrahmaSynthesis, 'neuronet/brahma_synthesis'
end
