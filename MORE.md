# MORE:

Here I go over my math for neuronet.rb.
Although I'm doing this from scratch,
no doubt that by now all I'm doing is re-discovering what's known
or just getting things horribly wrong.
:laughing:

# Mathematics of backpropagation

The following pseudo code is specifically
for neuronet.rb's FeedForward network.

```ruby
alias :| :squash
alias :^ :unsquash

# Consider a FeedForward network with N layers
n  ==  N - 1   # index of last layer, salida
m  ==  N - 2   # index of second last layer, yang
c  ==  i - 1   # refers to a connection typically found on the next layer, i-1

L0   # first layer, entrada
L1   # second layer, yin
Lm   # second last layer, yang
Ln   # last layer, salida

Li   # i-th layer
[Li]   # length of i-th layer

# General activation formula
network.layer[i].node[j].activation  ==
  | network.layer[i].node[j].bias +
    network.layer[i].node[j].connections.sum{|connection|
      connection.weight * connection.node.activation
    }

# or:
network.layer[i].node[j].activation  ==
  | network.layer[i].node[j].bias +
    (0...network.layer[i].node[j].connections.length).sum{|k|
      network.layer[i].node[j].connections[k].weight *
      network.layer[i].node[j].connections[k].node.activation}

# So, map the above to the following concise notation:
Aij  ==  | Bij + {k, Wijk*Ack}
# I considered Einstein notation, but
# decided to keep things in ASCII and explicit.

# The input layer:
Ij  ==  A0j

# The output layer:
Oj  ==  Anj

# Initial step up from input layer:
A1j  ==  | B1j + {k, W1jk*A0k}  ==
         | B1j + {k, W1jk*Ik}

# Consider a three layer feed forward network:
Oi  ==
A2i  ==  | B2i + {j, W2ij*A1j}  ==
         | B2i + {j, W2ij*| B1j + {k, W1jk*Ik}}

# A target for the unsquashed output, and
# an output with a deficit(error) E:
Ti  ==  Ei + ^ Oi   # adding E corrects ^O

# Remember that:
Oi  ==  | B2i + {j, W2ij*| B1j + {k, W1jk*Ik}}
# So...
Ti  ==  Ei + ^| B2i + {j, W2ij*| B1j + {k, W1jk*Ik}}
# and ^| goes away...
Ti  ==  Ei + B2i + {j, W2ij*| B1j + {k, W1jk*Ik}}

# Assume that the error E comes from errors in B and W equally:
Ti  ==  (B2i+e) + {j, (W2ij+e)*| (B1j+e) + {k, (W1jk+e)*Ik}}
    ==  Ei + ^ Oi

# OK, where does this go?
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| (B1j+e) + {k, (W1jk+e)*Ik}}  ==
# Decouple e in layer 1:
(B2i+e) + {j, (W2ij+e)*| B1j + e + {k, W1jk*Ik + e*Ik}}  ==
# Break apart the sum in layer 1:
(B2i+e) + {j, (W2ij+e)*| B1j + e + {k, W1jk*Ik} + {k, e*Ik}}  ==
# Rearrange components in layer 1:
(B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e + {k, e*Ik}}
(B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e + e*{k, Ik}}
(B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e*(1 + {k, Ik}}

# Lets define M1 as:
M1  ==  1 + {k, Ik}
# Then:
e*M1  ==  e*(1 + {k, Ik})

# Remember that:
(B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e*(1 + {k, Ik}}
# Substitute in e*M1:
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e*M1}
# I can almost get A1j back, if not for e*M1.
# I expect e*M1 to go to zero as e to goes to zero, so I'll use an approximation trick.

# The derivative of the sigmoid function:
Dx |[x] ==  |[x]*(1 - |[x])
# And remember that as e is small:
F[x+e]  =~  F[x] + e*Dx F[x]
# So:
| x + e  =~  |[x] + e*|[x]*(1 - |[x])

# Remember that:
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e*M1}
# So, substitute in A1j:
Ei + ^ Oi  =~  (B2i+e) + {j, (W2ij+e)*((A1j = | B1j + {k, W1jk*Ik}) + e*M1*A1j*(1 - A1j))}
           ==  (B2i+e) + {j, (W2ij+e)*(A1j + e*M1*A1j*(1 - A1j))}

# Terseness will really help in the coming steps.
# Define D as:
D1j  ==  A1j*(1 - A1j)

# Remember that:
Ei + ^ Oi  =~  (B2i+e) + {j, (W2ij+e)*(A1j + e*M1*A1j*(1 - A1j))}  ==
# Substitute in D:
(B2i+e) + {j, (W2ij+e)*(A1j + e*M1*D1j)}  ==
# Decoupling e in layer 2:
B2i + e + {j, (W2ij+e)*(A1j + e*M1*D1j)}  ==
B2i + e + {j, W2ij*(A1j + e*M1*D1j) + e*(A1j + e*M1*D1j)}  ==
# Expansion:
B2i + e + {j, W2ij*A1j + W2ij*e*M1*D1j + e*A1j + e*e*M1*D1j}  ==
# Break apart the sum in layer 2:
B2i + e + {j, W2ij*A1j} + {j, W2ij*e*M1*D1j} + {j, e*A1j} + {j, e*e*M1*D1j}  ==
# As e goes small, e*e vanishes:
B2i + e + {j, W2ij*A1j} + {j, W2ij*e*M1*D1j} + {j, e*A1j}  ==
# Rearrange:
B2i + {j, W2ij*A1j} + e + {j, e*A1j} + {j, W2ij*e*M1*D1j}
# Factor out e:
B2i + {j, W2ij*A1j} + e*(1 + {j, A1j} + {j, W2ij*M1*D1j})
# Factor out M1:
B2i + {j, W2ij*A1j} + e*(1 + {j, A1j} + M1*{j, W2ij*D1j})

# Define M2 as:
M2  ==  1 + {j, A1j}

# Remember that:
Ei + ^ Oi  =~  B2i + {j, W2ij*A1j} + e*(1 + {j, A1j} + M1*{j, W2ij*D1j})  ==
# Substitute in M2:
B2i + {j, W2ij*A1j} + e*(M2 + M1*{j, W2ij*D1j})

# Define K as
K2  ==  {j, W2ij*D1j}

# Remember that:
Ei + ^ Oi  =~  B2i + {j, W2ij*A1j} + e*(M2 + M1*{j, W2ij*D1j})  ==
# Substitute in K
B2i + {j, W2ij*A1j} + e*(M2 + K2*M1)  ==
# Substitute in A2i(=B2i + {j, W2ij*A1j}):
A2i + e*(M2 + K2*M1)  ==
# And since ^Oi == A2i:
^[Oi] + e*(M2 + K2*M1)

# So...
Ei + ^ Oi  =~  ^[Oi] + e*(M2 + K2*M1)
# Then...
Ei  =~  e*(M2 + K2*M1)
e  =~  Ei / (M2 + K2*M1)

# This deserves a box!
######################################
Ei  =~  e*(M2 + K2*M1)               #
M2  ==  1 + {j, A1j}                 #
K2  ==  {j, W2ij*D1j}                #
D1j  ==  A1j*(1 - A1j)               #
M1  ==  1 + {k, Ik}   # 1 + {k, A0k} #
######################################
e  =~  Ei/(M2 + K2*M1)               #
######################################

# All the components to compute e are available at each iteration.
# But we might choose to just do an estimate.
# D has a upper bound:
0.5*(1 - 0.5)  ==  0.25
0.49*(1 - 0.49)  ==  0.2499  <  0.25
0.51*(1 - 0.51)  ==  0.2499  <  0.25
Dij  <=  0.25

# So given e, E has an upper bound:
[Ei]  <=  [e*(M2 + 0.25*{j, W2ij}*M1)]   # Absolute values
[e]  >=  [Ei/(M2 + 0.25*{j, W2ij}*M1)]

# If we add a constraint on the weights of the nodes to:
[{j, W2ij}/4]  <=  1
# Then
[e]  >=  [Ei/(M2 + M1)]
```

[...AND MUCH MORE TODO:](TODO.md)
