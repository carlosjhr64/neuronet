# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Vishnu is a network which has its @yang layer initially "redux"(mirror and
  # "anti-mirror") it's input.  In the case of a four layer network, @yang
  # "redux" @yin.
  module Vishnu
    def self.bless(myself)
      myself.yang
      myself.extend Vishnu
      myself
    end

    def inspect
      "#Vishnu #{super}"
    end
  end
end
