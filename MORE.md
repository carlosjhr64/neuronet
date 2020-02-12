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

# Lets define M1 as:
M1  ==  e + {k, e*Ik}

# Remember that:
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + e + {k, e*Ik}}
# Substitute in M1:
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + M1}
# I can almost get A1j back, if not for M1.
# I expect M1 to go to zero as e to goes to zero, so I'll use an approximation trick.

# The derivative of the sigmoid function:
Dx |(x) ==  |(x)*(1 - |(x))
# And remember that as e is small:
F[x+e]  =~  F[x] + e*Dx F[x]
# So:
| x + e  =~  |(x) + e*|(x)*(1 - |(x))

# Remember that:
Ei + ^ Oi  ==  (B2i+e) + {j, (W2ij+e)*| B1j + {k, W1jk*Ik} + M1}
# So, substitute in A1j:
Ei + ^ Oi  =~  (B2i+e) + {j, (W2ij+e)*((A1j = | B1j + {k, W1jk*Ik}) + M1*A1j*(1-A1j))}
           ==  (B2i+e) + {j, (W2ij+e)*(A1j + M1*A1j*(1-A1j))}

# Terseness will really help in the coming steps.
# Define D as:
D1j  ==  A1j*(1-A1j)

# Remember that:
Ei + ^ Oi  =~  (B2i+e) + {j, (W2ij+e)*(A1j + M1*A1j*(1-A1j))}  ==
# Substitute in D:
(B2i+e) + {j, (W2ij+e)*(A1j + M1*D1j)}  ==
# Decoupling layer 2 e:
B2i + e + {j, (W2ij+e)*(A1j + M1*D1j)}  ==
B2i + e + {j, W2ij*(A1j + M1*D1j) + e*(A1j + M1*D1j)}  ==
# Expansion:
B2i + e + {j, W2ij*A1j + W2ij*M1*D1j + e*A1j + e*M1*D1j}  ==
# Break apart the sum in layer 2:
B2i + e + {j, W2ij*A1j} + {j, W2ij*M1*D1j} + {j, e*A1j} + {j, e*M1*D1j}  ==
# Rearrange:
B2i + {j, W2ij*A1j} + e + {j, e*A1j} + {j, W2ij*M1*D1j} + {j, e*M1*D1j}

# Lets define M2 as:
M2  ==  e + {j, e*A1j}

# Remember that:
Ei + ^ Oi  =~
B2i + {j, W2ij*A1j} + e + {j, e*A1j} + {j, W2ij*M1*D1j} + {j, e*M1*D1j}  ==
# And substitute in M2:
B2i + {j, W2ij*A1j} + M2 + {j, W2ij*M1*D1j} + {j, e*M1*D1j}  ==
# And substitute in ^(A2i) = B2i + {j, W2ij*A1j}):
^(A2i) + M2 + {j, W2ij*M1*D1j} + {j, e*M1*D1j}  ==
# Substitute in Oi( = A2i):
^(Oi) + M2 + {j, W2ij*M1*D1j} + {j, e*M1*D1j}

#So:
Ei + ^(Oi)  =~  ^(Oi) + M2 + {j, W2ij*M1*D1j} + {j, e*M1*D1j}
Ei  =~  M2 + {j, W2ij*M1*D1j} + {j, e*M1*D1j}  ==
        M2 + {j, W2ij*D1j*M1} + {j, e*D1j*M1}  ==
        M2 + {j, W2ij*D1j*M1 + e*D1j*M1}  ==
        M2 + D1j*M1*{j, W2ij + e}  ==
        M2 + D1j*{j, W2ij + e}*M1
# This deserves a box!

###############################################################
Ei  =~  M2 + D1j*{j, W2ij +  e}*M1
M2  ==  e + {j, e*A1j}
M1  ==  e + {k, e*Ik}   # e + {k, e*A0k}
D1j  ==  A1j*(1 - A1j)
###############################################################
```

[...AND MUCH MORE TODO:](TODO.md)