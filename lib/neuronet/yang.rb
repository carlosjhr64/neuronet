# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Yang is a network which has its @salida(the output layer) initially
  # mirroring @yang(that just prior to the output layer).
  module Yang
    def self.bless(myself, sign = 1)
      myself.salida.mirror(sign)
      myself.extend Yang
      myself
    end

    def inspect
      "#Yang #{super}"
    end
  end
end
