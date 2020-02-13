# MORE:

## Mathematics of backpropagation

The following is pseudo code.

```ruby
alias :| :squash
alias :^ :unsquash

# General activation formula as expressed in neuronet.rb:
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
Aij  ==  | Bij + {k, Wijk*Ack}    # in neuronet.rb, c typically is i-1
# I considered Einstein notation, but
# decided to keep things in ASCII and explicit.

# The input layer:
Ij  ==  A0j

# The output layer:
Oj  ==  Anj   # where n is the index of the last layer.

# Initial step up from input layer:
A1j  ==  | B1j + {k, W1jk*A0k}  ==
         | B1j + {k, W1jk*Ik}

# Let's just consider a three layer feed forward network, as
# I'll show that's going to be enough to analyze backpropagation:
Oi  ==
A2i  ==  | B2i + {j, W2ij*A1j}  ==
         | B2i + {j, W2ij*| B1j + {k, W1jk*Ik}}

# We have some target for the unsquashed output, and
# the output has a deficit(error) E:
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
# Decoupled e in layer 1:
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
Dx |(x) ==  |(x)*(1 - |(x))
# And remember that as e is small:
F[x+e]  =~  F[x] + e*Dx F[x]
# So:
| x + e  =~  |(x) + e*|(x)*(1 - |(x))

# Remember that:
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e*M1}
# So, substitute in A1j:
Ei + ^ Oi  =~  (B2i+e) + {j, (W2ij+e)*((A1j = | B1j + {k, W1jk*Ik}) + e*M1*A1j*(1-A1j))}
           ==  (B2i+e) + {j, (W2ij+e)*(A1j + e*M1*A1j*(1-A1j))}

# Terseness will really help in the coming steps.
# Define D as:
D1j  ==  A1j*(1-A1j)

# Remember that:
Ei + ^ Oi  =~  (B2i+e) + {j, (W2ij+e)*(A1j + e*M1*A1j*(1-A1j))}  ==
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
B2i + {j, W2ij*A1j} + e*(1 + {j, A1j}) + {j, W2ij*e*M1*D1j}

# Lets define M2 as:
M2  ==  1 + {j, A1j}
# Then:
e*M2  == e*(1 + {j, A1j})

# Remember that:
Ei + ^ Oi  =~  B2i + {j, W2ij*A1j} + e*(1 + {j, A1j}) + {j, W2ij*e*M1*D1j}  ==
# And substitute in e*M2:
B2i + {j, W2ij*A1j} + e*M2 + {j, W2ij*e*M1*D1j}  ==
# And substitute in ^(A2i) = B2i + {j, W2ij*A1j}):
^(A2i) + e*M2 + {j, W2ij*e*M1*D1j} + {j, e*e*M1*D1j}  ==
# Substitute in Oi( = A2i):
^(Oi) + e*M2 + {j, W2ij*e*M1*D1j} + {j, e*e*M1*D1j}

#So:
Ei + ^(Oi)  =~  ^(Oi) + e*M2 + {j, W2ij*e*M1*D1j}
Ei  =~  e*M2 + {j, W2ij*e*M1*D1j}
# Factor out e and rearrange:
Ei  =~  e*(M2 + {j, W2ij*D1j*M1})
# This deserves a box!

########################################
Ei  =~  e*(M2 + {j, W2ij*D1j*M1})      #
M2  ==  1 + {j, A1j}                   #
M1  ==  1 + {k, Ik}   # 1 + {k, A0k}   #
D1j  ==  A1j*(1 - A1j)                 #
########################################
e  =~  Ei/(M2 + {j, W2ij*D1j*M1})      #
########################################

# All the components to compute e are available at each iteration.
# But we might choose to just do an estimate.
# D has a upper bound:
0.5*(1-0.5)  ==  0.25
0.49*(1-0.49)  ==  0.2499  <  0.25
0.51*(1-0.51)  ==  0.2499  <  0.25
Dij  <  0.25

# So given e, E has an upper bound:
Ei  <  e*(M2 + 0.25*{j, W2ij}*M1)

# W can be positive, negative...
# Maybe I can argue that it averages around zero?
# If W has some average absolute value, w...
# random walk of step w?
Ei  ~  e*(M2 + (w/4)*Sqrt({j, 1})*M1)
# Define L
Lj  ==  {j, 1}   # The length j runs
# Then
Ei  ~  e*(M2 + (w/4)*Sqrt(Lj)*M1)

# Just try an order of magnitude estimate?
Ei  ~  e*(M2 + Sqrt(Lj)*M1)
e  ~  Ei/(M2 + Sqrt(Lj)*M1)

# So I said I would show that's enough!?
# Not sure, actually....
# I think I need to do one more layer to see a pattern.
#   :P
```

[...AND MUCH MORE TODO:](TODO.md)
