# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Neo is a network which has its @yang layer initially mirroring it's input.
  module Neo
    def self.bless(myself)
      myself.yang.mirror
      myself.extend Neo
      myself
    end

    def inspect
      "#Neo #{super}"
    end
  end
end
