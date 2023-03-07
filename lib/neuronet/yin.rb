# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Yin is a network which has its @yin layer initially mirroring @entrada.
  module Yin
    def self.bless(myself)
      myself.yin.mirror
      myself.extend Yin
      myself
    end

    def inspect
      "#Yin #{super}"
    end
  end
end
