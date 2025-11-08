# frozen_string_literal: true

# Neuronet
module Neuronet
  VERSION = '8.0.251108'

  autoload :Arrayable,          'neuronet/arrayable'
  autoload :Exportable,         'neuronet/exportable'
  autoload :Squash,             'neuronet/squash'
  autoload :Connection,         'neuronet/connection'
  autoload :Clamp,              'neuronet/clamp'
  autoload :Backpropagate,      'neuronet/backpropagate'
  autoload :NoisyBackpropagate, 'neuronet/noisy_backpropagate'
  autoload :LayerPresets,       'neuronet/layer_presets'
  autoload :Trainable,          'neuronet/trainable'
  autoload :NeuronStats,        'neuronet/neuron_stats'
  autoload :NetworkStats,       'neuronet/network_stats'
  autoload :InputNeuron,        'neuronet/input_neuron'
  autoload :MiddleNeuron,       'neuronet/middle_neuron'
  autoload :OutputNeuron,       'neuronet/output_neuron'
  autoload :Neuron,             'neuronet/neuron'
  autoload :NoisyMiddleNeuron,  'neuronet/noisy_middle_neuron'
  autoload :NoisyOutputNeuron,  'neuronet/noisy_output_neuron'
  autoload :NoisyNeuron,        'neuronet/noisy_neuron'
  autoload :InputLayer,         'neuronet/input_layer'
  autoload :MiddleLayer,        'neuronet/middle_layer'
  autoload :OutputLayer,        'neuronet/output_layer'
  autoload :Layer,              'neuronet/layer'
  autoload :Perceptron,         'neuronet/perceptron'
  autoload :MLP,                'neuronet/mlp'
  autoload :Deep,               'neuronet/deep'
  autoload :FeedForward,        'neuronet/feed_forward'
end
