# frozen_string_literal: true

# Neuronet module
module Neuronet
  # A Perceptron Hybrid,
  # Tao directly connects the output layer to the input layer.
  module Tao
    # Tao.bless connects the network's output layer to the input layer.
    def self.bless(myself)
      # salida directly connects to entrada
      myself.salida.connect(myself.entrada)
      myself.extend Tao
      myself
    end

    def inspect
      "#Tao #{super}"
    end

    # The obvious Tao ScaledNetwork
    def self.[](size)
      Tao.bless ScaledNetwork.new([size, size, size])
    end
  end
end
