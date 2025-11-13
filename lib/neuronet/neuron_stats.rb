# frozen_string_literal: true

module Neuronet
  # NeuronStats provides network analysis methods.
  module NeuronStats
    # Returns the total tally of parameters in the downstream
    # network subgraph from this neuron.
    # This includes the neuron's bias (1 parameter),
    # the weights of its incoming connections (one per connection),
    # and the sum of parameters from all downstream neurons.
    # Parameters from a shared neuron are counted multiple times
    # if accessed via multiple pathways,
    # reflecting the total parameter influence through all paths.
    # Returns 0 for a neuron with no downstream connections.
    def downstream_params_tally
      return 0 if (size = connections.size).zero?

      1 + size + connections.sum { it.neuron.downstream_params_tally }
    end

    # Sum of activations + 1.  It's a component of the sensitivity measure nju.
    # See [wiki](https://github.com/carlosjhr64/neuronet/wiki)
    def mju = 1 + connections.sum { it.neuron.activation }

    # Sensitivity measure nju:
    #     𝒆 ~ 𝜀𝝁 + 𝑾 𝓑𝒂'𝒆'
    #     𝝂 ≜ 𝒆/𝜀
    #     𝝂 ~ 𝝁 + 𝑾 𝓑𝒂'𝝂'
    # See the [wiki](https://github.com/carlosjhr64/neuronet/wiki)
    # See also test/tc_epsilon:
    #     https://github.com/carlosjhr64/neuronet/blob/master/test/tc_epsilon
    def nju
      return 0 if connections.empty?

      mju + connections.sum do |connection|
        neuron = connection.neuron
        next 0.0 if (n = neuron.nju).zero? || (a = neuron.activation) >= 1.0

        connection.weight * a * (1.0 - a) * n
      end
    end
  end
end
