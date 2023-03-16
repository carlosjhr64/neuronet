# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Yin is a network which has its @yin layer(that after the input layer)
  # initially mirroring @entrada(the input layer).
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
