# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Brahma is a network which has its @yin layer initially "redux"(mirror and
  # "anti-mirror") @entrada.
  module Brahma
    def self.bless(myself)
      myself.yin.redux
      myself.extend Brahma
      myself
    end

    def inspect
      "#Brahma #{super}"
    end
  end
end
