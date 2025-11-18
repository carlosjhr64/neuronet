Gem::Specification.new do |s|
  ## INFO ##
  s.name     = 'neuronet'
  s.version  = '9.0.251116'
  s.homepage = 'https://github.com/carlosjhr64/neuronet'
  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'
  s.date     = '2025-11-18'
  s.licenses = ['MIT']
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    Library to create neural networks.
  SUMMARY
  s.description = <<~DESCRIPTION
    Library to create neural networks.
    
    Features perceptron, MLP, and deep feed forward networks.
    Uses a logistic squash function.
  DESCRIPTION
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
    CREDITS.md
    README.md
    lib/neuronet.rb
    lib/neuronet/arrayable.rb
    lib/neuronet/backpropagate.rb
    lib/neuronet/config.rb
    lib/neuronet/connection.rb
    lib/neuronet/deep.rb
    lib/neuronet/exportable.rb
    lib/neuronet/feed_forward.rb
    lib/neuronet/input_layer.rb
    lib/neuronet/input_neuron.rb
    lib/neuronet/layer.rb
    lib/neuronet/layer_presets.rb
    lib/neuronet/middle_layer.rb
    lib/neuronet/middle_neuron.rb
    lib/neuronet/mlp.rb
    lib/neuronet/network_stats.rb
    lib/neuronet/neuron.rb
    lib/neuronet/neuron_stats.rb
    lib/neuronet/noisy_backpropagate.rb
    lib/neuronet/noisy_middle_neuron.rb
    lib/neuronet/noisy_neuron.rb
    lib/neuronet/noisy_output_neuron.rb
    lib/neuronet/output_layer.rb
    lib/neuronet/output_neuron.rb
    lib/neuronet/perceptron.rb
    lib/neuronet/squash.rb
    lib/neuronet/trainable.rb
  ]
  
  ## REQUIREMENTS ##
  s.required_ruby_version = '>= 3.4'
end
