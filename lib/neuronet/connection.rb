# frozen_string_literal: true

module Neuronet
  # Connection is a lightweight struct for weighted neuron links.
  Connection = Struct.new('Connection', :neuron, :weight) do
    # Weighted activation value
    def value = neuron.activation * weight
  end
end
