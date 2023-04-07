# frozen_string_literal: true

# Neuronet/Brahma module
module Neuronet
  # Brahma is a network which has its @yin layer initially
  # "antithesis" @entrada.
  module Brahma
    def self.bless(myself)
      myself.yin.antithesis
      myself.extend Brahma
      myself
    end

    def inspect
      "#Brahma #{super}"
    end
  end
end
