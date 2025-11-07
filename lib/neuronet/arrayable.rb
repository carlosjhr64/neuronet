# frozen_string_literal: true

module Neuronet
  # Arrayable avoids explicit `to_a` calls for common Array methods.
  module Arrayable
    def each(&blk) = to_a.each { blk[it] }
    def each_with_index(&blk) = to_a.each_with_index { |n, i| blk[n, i] }
    def [](index) = to_a[index]
    def map(&) = to_a.map(&)
    def size = to_a.size
    def reverse = to_a.reverse
  end
end
