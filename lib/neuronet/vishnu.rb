# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Vishnu is a network which has its @yang layer initially
  # "average" it's input.
  module Vishnu
    def self.bless(myself)
      myself.yang.average
      myself.extend Vishnu
      myself
    end

    def inspect
      "#Vishnu #{super}"
    end
  end
end
