# frozen_string_literal: true

module Neuronet
  # Network Stats
  module NetworkStats
    # See https://github.com/carlosjhr64/neuronet/wiki
    # |𝝂| = 𝔪 + ¼√𝑁*𝔪' + ¼√𝑁*¼√𝑁'*𝔪" + ...
    def expected_nju!
      nju = 0.0
      mult = 1.0
      reverse[1..].each do |layer|
        size = layer.size
        mju = 1 + (0.5 * size)
        nju += mult * mju
        mult *= 0.25 * Math.sqrt(size)
      end
      @expected_nju = nju
    end

    def expected_nju
      @expected_nju || expected_nju!
    end

    def njus
      output_layer.map(&:nju)
    end
  end
end
