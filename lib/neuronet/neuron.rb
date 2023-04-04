# frozen_string_literal: true

# Neuronet module / Neuron class
module Neuronet
  # A Neuron is a capable of creating connections to other neurons.  The
  # connections attribute is a list of the neuron's connections to other
  # neurons.  A neuron's bias is it's kicker (or deduction) to it's activation
  # value, a sum of its connections values.
  class Neuron
    # For bookkeeping, each Neuron is given a label, starting with 'a' by
    # default.
    class << self; attr_accessor :label; end
    Neuron.label = 'a'

    attr_reader :label, :activation, :connections
    attr_accessor :bias

    # The neuron's mu is the sum of the connections' mu(activation), plus one
    # for the bias:
    #   𝛍 := 1+∑𝐚'
    def mu
      return Neuronet.zero if @connections.empty?

      1 + @connections.sum(Neuronet.zero, &:mu)
    end

    # Reference the library's wiki:
    #   𝒆ₕ ~ 𝜀(𝝁ₕ + 𝜧ₕⁱ𝝁ᵢ + 𝜧ₕⁱ𝜧ᵢʲ𝝁ⱼ + 𝜧ₕⁱ𝜧ᵢʲ𝜧ⱼᵏ𝝁ₖ + ...)
    # 𝜧ₕⁱ𝝁ᵢ is:
    #   neuron.mju{ |connected_neuron| connected_neuron.mu }
    # 𝜧ₕⁱ𝜧ᵢʲ𝝁ⱼ is:
    #   nh.mju{ |ni| ni.mju{ |nj| nj.mu }}
    def mju(&block)
      @connections.sum(Neuronet.zero) { _1.mju * block[_1.neuron] }
    end

    # 𝓓𝒗⌈𝒗 = (1-⌈𝒗)⌈𝒗 = (1-𝒂)𝒂 = 𝓑𝒂
    def derivative = Neuronet.derivative[@activation]

    # 𝝀 = 𝓑𝒂𝛍
    def lamda = derivative * mu

    # 𝜿 := 𝜧 𝝁' = 𝑾 𝓑𝒂'𝝁' = 𝑾 𝝀'
    # def kappa = mju(&:mu)
    def kappa = @connections.sum(Neuronet.zero, &:kappa)

    # 𝜾 := 𝜧 𝜧' 𝝁" = 𝜧 𝜿'
    def iota = mju(&:kappa)

    # One can explicitly set the neuron's value, typically used to set the input
    # neurons.  The given "real world" value is squashed into the neuron's
    # activation value.
    def value=(value)
      # If value is out of bounds, set it to the bound.
      if value.abs > Neuronet.maxv
        value = value.positive? ? Neuronet.maxv : -Neuronet.maxv
      end
      @activation = Neuronet.squash[value]
    end

    # The "real world" value of the neuron is the unsquashed activation value.
    def value = Neuronet.unsquash[@activation]

    # The initialize method sets the neuron's value, bias and connections.
    def initialize(value = Neuronet.vzero, bias: Neuronet.zero, connections: [])
      self.value   = value
      @connections = connections
      @bias        = bias
      @label       = Neuron.label
      Neuron.label = Neuron.label.next
    end

    # Updates the activation with the current value of bias and updated values
    # of connections.
    def update
      return @activation if @connections.empty?

      self.value = @bias + @connections.sum(Neuronet.zero, &:update)
      @activation
    end

    # For when connections are already updated, Neuron#partial updates the
    # activation with the current values of bias and connections.  It is not
    # always necessary to burrow all the way down to the terminal input neuron
    # to update the current neuron if it's connected neurons have all been
    # updated.  The implementation should set it's algorithm to use partial
    # instead of update as update will most likely needlessly update previously
    # updated neurons.
    def partial
      return @activation if @connections.empty?

      self.value = @bias + @connections.sum(Neuronet.zero, &:partial)
      @activation
    end

    # The backpropagate method modifies the neuron's bias in proportion to the
    # given error and passes on this error to each of its connection's
    # backpropagate method.  While updates flows from input to output, back-
    # propagation of errors flows from output to input.
    def backpropagate(error)
      return self if @connections.empty?

      @bias += Neuronet.noise[error]
      if @bias.abs > Neuronet.maxb
        @bias = @bias.positive? ? Neuronet.maxb : -Neuronet.maxb
      end
      @connections.each { |connection| connection.backpropagate(error) }
      self
    end

    # Connects the neuron to another neuron.  Updates the activation with the
    # new connection.  The default weight=0 means there is no initial
    # association.  The connect method is how the implementation adds a
    # connection, the way to connect the neuron to another.  To connect "salida"
    # to "entrada", for example, it is:
    #	  entrada = Neuronet::Neuron.new
    #	  salida = Neuronet::Neuron.new
    #	  salida.connect(entrada)
    # Think output(salida) connects to input(entrada).
    def connect(neuron = Neuron.new, weight: Neuronet.zero)
      @connections.push(Connection.new(neuron, weight:))
      # Note that we're returning the connected neuron:
      neuron
    end

    # Tacks on to neuron's inspect method to show the neuron's bias and
    # connections.
    def inspect
      fmt = Neuronet.format
      if @connections.empty?
        "#{@label}:#{fmt % value}"
      else
        "#{@label}:#{fmt % value}|#{[(fmt % @bias), *@connections].join('+')}"
      end
    end

    # A neuron plainly puts itself as it's label.
    def to_s = @label
  end
end
