# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Shiva is a network which has its @salida layer initially "redux"(mirror and
  # "shadow" @yang.
  module Shiva
    def self.bless(myself)
      myself.salida.redux
      myself.extend Shiva
      myself
    end

    def inspect
      "#Shiva #{super}"
    end
  end
end
