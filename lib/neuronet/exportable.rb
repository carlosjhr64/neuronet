# frozen_string_literal: true

module Neuronet
  # Exportable serializes network biases and weights only.
  # Human-readable, compact, excludes activations.
  module Exportable
    # Writes serialized network to writer(from self).
    # rubocop: disable Metrics
    def export(writer)
      sizes = map(&:size)
      writer.puts "# #{self.class}"
      # The first "float" here is the number of layers in the FFN...
      # Just to be consistent:
      writer.puts "#{sizes.size.to_f} #{sizes.join(' ')}"
      each_with_index do |layer, i|
        next if i.zero? # skip input layer

        layer.each_with_index do |neuron, j|
          writer.puts "# neuron = FFN[#{i}, #{j}]"
          writer.puts "#{neuron.bias} #{i} #{j}"
          neuron.connections.each_with_index do |connection, k|
            writer.puts "#{connection.weight} #{i} #{j} #{k}"
          end
        end
      end
    end
    # rubocop: enable Metrics

    def export_to_file(filename) = File.open(filename, 'w') { export it }
    def import_from_file(filename) = File.open(filename, 'r') { import it }

    # Reads and validates serialized network from reader to set self.
    # rubocop: disable Metrics
    def import(reader)
      gets_data = lambda do |reader|
        return nil unless (line = reader.gets)

        line = reader.gets while line.start_with?('#')
        fs, *is = line.strip.split
        [fs.to_f, *is.map(&:to_i)]
      end

      size, *sizes = gets_data[reader]
      raise 'Size/Sizes mismatch' unless size == sizes.size
      raise 'Sizes mismatch' unless sizes == map(&:size)

      each_with_index do |layer, i|
        next if i.zero? # skip input layer

        layer.each_with_index do |neuron, j|
          bias, *indeces = gets_data[reader]
          raise "bad bias index: #{indeces}" unless indeces == [i, j]

          neuron.bias = bias
          neuron.connections.each_with_index do |connection, k|
            weight, *indeces = gets_data[reader]
            raise "bad weight index: #{indeces}" unless indeces == [i, j, k]

            connection.weight = weight
          end
        end
      end
      raise 'Expected end of file.' unless gets_data[reader].nil?
    end
    # rubocop: enable Metrics
  end
end
