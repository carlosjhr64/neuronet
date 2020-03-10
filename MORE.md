# MORE:

Here I go over my math for neuronet.rb.

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
# And the index of entrada and yin are 0 and 1 respectively.

L0   # first layer, entrada
L1   # second layer, yin
Lm   # second last layer, yang
Ln   # last layer, salida

Li     # i-th layer
[Li]   # length of i-th layer
Lc     # the connected layer(likely to be i-1)
[Lc]   # length of the connected layer

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

# The input layer:
Ij  ==  A0j

# The output layer:
Oj  ==  Anj

# Initial step up from input layer:
A1j  ==  | B1j + {k, W1jk*A0k}  ==
         | B1j + {k, W1jk*Ik}

# Consider a three layer FeedForward network:
Oj  ==  Anj  ==  A2j   # n==2 for a 3 layer FF
    ==  | B2j + {k, W2jk*A1k}
# Substitute in the expansion of A1j:
    ==  | B2j + {k, W2jk*| B1k + {l, W1kl*Il}}

# A target for the unsquashed output, and
# an output with a deficit(error) E:
Tj  ==  Ej + ^ Oj   # adding E corrects ^O

# Remember that:
Oj  ==  | B2j + {k, W2jk*| B1k + {l, W1kl*Il}}
# So...
Tj  ==  Ej + ^| B2j + {k, W2jk*| B1k + {l, W1kl*Il}}
# and ^| goes away...
Tj  ==  Ej + B2j + {k, W2jk*| B1k + {l, W1kl*Il}}

# Assume that the error E comes from errors in B and W equally:
Tj  ==  (B2j+e) + {k, (W2jk+e)*| (B1k+e) + {l, (W1kl+e)*Il}}
    ==  Ej + ^ Oj

# OK, where does this go?
Ej + ^ Oj  ==  (B2j+e) + {k, (W2jk+e)*| (B1k+e) + {l, (W1kl+e)*Il}}  ==
# Decouple e in layer 1:
(B2j+e) + {k, (W2jk+e)*| B1k + e + {l, W1kl*Il + e*Il}}  ==
# Break apart the sum in layer 1:
(B2j+e) + {k, (W2jk+e)*| B1k + e + {l, W1kl*Il} + {l, e*Il}}  ==
# Rearrange components in layer 1:
(B2j+e) + {k, (W2jk+e)*| B1k + {l, W1kl*Il} + e + {l, e*Il}}
(B2j+e) + {k, (W2jk+e)*| B1k + {l, W1kl*Il} + e + e*{l, Il}}
(B2j+e) + {k, (W2jk+e)*| B1k + {l, W1kl*Il} + e*(1 + {l, Il}}

# Lets define M1 as:
M1  ==  1 + {k, Il}  ==  1 + {l, A0l}
# Then:
e*M1  ==  e*(1 + {l, Il})

# Remember that:
(B2j+e) + {k, (W2jk+e)*| B1k + {l, W1kl*Il} + e*(1 + {l, Il}}
# Substitute in e*M1:
Ej + ^ Oj  ==  (B2j+e) + {k, (W2jk+e)*| B1k + {l, W1kl*Il} + e*M1}
# I can almost get A1j back, if not for e*M1.
# I expect e*M1 to go to zero as e to goes to zero,
# so I'll use an approximation trick.

# The derivative of the sigmoid function:
Dx |[x] ==  |[x]*(1 - |[x])
# And remember that as e is small:
F[x+e]  =~  F[x] + e*Dx F[x]
# So:
| x + e  =~  |[x] + e*|[x]*(1 - |[x])

# Remember that:
Ej + ^ Oj  ==  (B2j+e) + {k, (W2jk+e)*| B1k + {l, W1kl*Il} + e*M1}
# So, substitute in A1j:
Ej + ^ Oj
=~  (B2j+e) + {k, (W2jk+e)*((A1k== | B1k + {l, W1kl*Il}) + e*M1*A1k*(1 - A1k))}
==  (B2j+e) + {k, (W2jk+e)*(A1k + e*M1*A1k*(1 - A1k))}

# Terseness will really help in the coming steps.
# Define D as:
D1k  ==  A1k*(1 - A1k)

# Remember that:
Ej + ^ Oj  =~  (B2j+e) + {k, (W2jk+e)*(A1k + e*M1*A1k*(1 - A1k))}  ==
# Substitute in D:
(B2j+e) + {k, (W2jk+e)*(A1k + e*M1*D1k)}  ==
# Decoupling e in layer 2:
B2j + e + {k, (W2jk+e)*(A1k + e*M1*D1k)}  ==
B2j + e + {k, W2jk*(A1k + e*M1*D1j) + e*(A1k + e*M1*D1k)}  ==
# Expansion:
B2j + e + {k, W2jk*A1k + W2jk*e*M1*D1k + e*A1k + e*e*M1*D1k}  ==
# Break apart the sum in layer 2:
B2j + e + {k, W2jk*A1k} + {k, W2jk*e*M1*D1j} + {k, e*A1k} + {k, e*e*M1*D1k}  ==
# As e goes small, e*e vanishes:
B2j + e + {k, W2jk*A1k} + {k, W2jk*e*M1*D1k} + {k, e*A1k}  ==
# Rearrange:
B2j + {k, W2jk*A1k} + e + {k, e*A1k} + {k, W2jk*e*M1*D1k}
# Factor out e:
B2j + {k, W2jk*A1k} + e*(1 + {j, A1k} + {k, W2jk*M1*D1k})
# Factor out M1:
B2j + {k, W2jk*A1k} + e*(1 + {j, A1k} + M1*{k, W2jk*D1k})

# Define M2 as:
M2  ==  1 + {k, A1k}

# Remember that:
Ej + ^ Oj  =~  B2j + {k, W2jk*A1k} + e*(1 + {k, A1k} + M1*{k, W2jk*D1k})  ==
# Substitute in M2:
B2j + {k, W2jk*A1k} + e*(M2 + M1*{k, W2jk*D1k})

# Define K as
K2j  ==  {k, W2jk*D1k}

# Remember that:
Ej + ^ Oj  =~  B2j + {k, W2jk*A1k} + e*(M2 + M1*{k, W2jk*D1k})  ==
# Substitute in K
B2j + {k, W2jk*A1k} + e*(M2 + K2j*M1)  ==
# Substitute in A2j(=B2j + {k, W2jk*A1k}):
A2j + e*(M2 + K2j*M1)  ==
# And since ^Oj == A2j:
^[Oj] + e*(M2 + K2j*M1)

# So...
Ej + ^ Oj  =~  ^[Oj] + e*(M2 + K2j*M1)
# Then...
Ej  =~  e*(M2 + K2j*M1)
e  =~  Ej / (M2 + K2j*M1)

# This deserves a box!
######################################
Ej  =~  e*(M2 + K2j*M1)              #
M2  ==  1 + {k, A1k}                 #
K2j  ==  {k, W2jk*D1k}               #
D1k  ==  A1k*(1 - A1k)               #
M1  ==  1 + {l, Il}   # 1 + {l, A0l} #
######################################
e  =~  Ej/(M2 + K2j*M1)              #
######################################

# All the components to compute e are available at each iteration.
# But we might choose to just do an estimate.
# D has a upper bound:
0.5*(1 - 0.5)  ==  0.25
0.49*(1 - 0.49)  ==  0.2499  <  0.25
0.51*(1 - 0.51)  ==  0.2499  <  0.25
Dij  <=  0.25

# So given e, E has an upper bound:
[Ej]  <=  [e*(M2 + 0.25*{k, W2jk}*M1)]   # Absolute values
[e]  >=  [Ej/(M2 + 0.25*{k, W2jk}*M1)]

# If we add a constraint on the weights of the nodes to:
[{k, W2jk}/4]  <=  1
# Then
[e]  >=  [Ej/(M2 + M1)]

# For a FeedForward network,
# M can be thought of as a property of the layer
# (it is a property of the neuron all neurons in a layer see the same).
# But K remains an individual property of a neuron.
# For FeedForward, that's Mip==Miq but Kip!=Kiq in general.

# Let's get rid of the index baggage,
# except where I need to make a distinction
# I'll mark with c when referring to a connected neuron
# (as opposed to self):

# In general:
A  ==  | B + {W*Ac}
M  ==  1 + {Ac}
D  ==  A*(1 - A)
K  ==  {W*Dc}
A + D*E  =~  | ^[A] + E
# Equipartion of E to e:
^[A] + E  =~  (B+e) + {(W+e)*(Ac+Dc*Ec)}
# For FeedForward only:
{M*x}  ==  M*{x}   # M is just a constant of the next layer

# Now let's get the box for many layers:
^[A] + E
(B+e) + {(W+e)*(Ac+Dc*Ec)}
B + e + {(W + e)*(Ac + Dc*Ec)}
B + e + {W*Ac + W*Dc*Ec + e*Ac + e*Dc*EC}
B + e + {W*Ac} + {W*Dc*Ec} + {e*Ac} + {e*Dc*EC}
B + e + {W*Ac} + {W*Dc*Ec} + {e*Ac}   # e*D*E vanishingly small
B + {W*Ac} + e + {e*Ac} + {W*Dc*Ec}
B + {W*Ac} + e*(1 + {Ac}) + {W*Dc*Ec}
B + {W*Ac} + e*M + {W*Dc*Ec}
^[A] + e*M + {W*Dc*Ec}

# In general(not just FeedForward):
##########################
E  =~  e*M + {W*Dc*Ec}   #
##########################

# For FeedForward:
En  =~ e*Mn + {Wn*Dm*Em}   # And goes on...
# ...                      # how ever many...
E3  =~ e*M3 + {W3*D2*E2}
E2  =~ e*M2 + {W2*D1*E1}
E1  =~ e*M1 + {W1*D0*E0}   # until done.
# But we specify that the input is error free:
E0  ==  0
E1  =~ e*M1

### E1(Perceptron) ###
E1  =~  e*M1         #
 e  =~  E1/M1        #
######################

# E2:
E2  =~  e*M2 + {W2*D1*E1}
==  e*M2 + {W2*D1*(e*M1)}
==  e*M2 + e*M1*{W2*D1}   # for FF, M1 is constant

### E2 ####################
E2  =~  e*M2 + e*M1*K2    #
 e  =~  E2/(M2 + K2*M1)   #
###########################

# E3:
E3  =~ e*M3 + {W3*D2*E2}
==  e*M3 + {W3*D2*(e*M2 + e*M1*K2)}
==  e*M3 + {W3*D2*e*(M2 + M1*K2)}
==  e*M3 + e*{W3*D2*(M2 + M1*K2)}
==  e*(M3 + {W3*D2*(M2 + M1*K2)})
==  e*(M3 + {W3*D2*M2 + W3*D2*M1*K2})
==  e*(M3 + {W3*D2*M2} + {W3*D2*M1*K2})
==  e*(M3 + {W3*D2}*M2 + {W3*D2*K2}*M1)
==  e*(M3 + K3*M2 + {W3*D2*K2}*M1)

# Have to expand:
{W3*D2*K2}
{k, W3jk*D2k*K2k}
# Old definition of K:
K3j  ==  {k, W3jk*D2k}
# New definition of K:
K3j  ==  K3j[1]  ==  {k, W3jk*D2k*1}
K3j[K2]  ==  {k, W3jk*D2k*K2k}
# Let:
K3[K2]  =  {W3*D2*K2}
# So:
K3  ==  K3[1]  ==  {W3*D2}
K3[K2]  ==  {W3*D2*K2}

# Remember where we left off above:
e*(M3 + K3*M2 + {W3*D2*K2}*M1)
e*(M3 + K3*M2 + K3[K2]*M1)

### E3 ################################
E3  =~ e*(M3 + K3*M2 + K3[K2]*M1)     #
 e  =~  E3/(M3 + K3*M2 + K3[K2]*M1)   #
#######################################

# E4:
E4  =~  e*M4 + {W4*D3*E3}
==  e*M4 + {W4*D3*e*(M3 + K3*M2 + K3[K2]*M1)}
==  e*M4 + e*{W4*D3*(M3 + K3*M2 + K3[K2]*M1)}
==  e*(M4 + {W4*D3*(M3 + K3*M2 + K3[K2]*M1)})

# Consider just:
M4 + {W4*D3*(M3 + K3*M2 + K3[K2]*M1)}
M4 + K4[M3 + K3*M2 + K3[K2]*M1]
M4 + K4[M3] + K4[K3*M2] + K4[K3[K2]*M1]
M4 + K4*M3 + K4[K3]*M2 + K4[K3[K2]]*M1

### E4 ################################################
E4  =~  e*(M4 + K4*M3 + K4[K3]*M2 + K4[K3[K2]]*M1)    #
 e  =~  E3/(M4 + K4*M3 + K4[K3]*M2 + K4[K3[K2]]*M1)   #
#######################################################
# And I think we finally got a pattern.

# TODO: Need to investigate the behavior of `K[K]`
# Is what follows below still correct?

# Again if K<=1, or K=~1...
[K]  <=  1   ==>   [E]  <=  [e*{M}]
[K]  =~  1   ==>   [E]  =~  [e*{M}]

# Remember that:
K  ==  {W*D}
# If instead of [K] =~ 1:
[W*D]  =~  1   and   RANDOM{W}
# Then K goes as the number of connections:
[K]  ~~  Lc
# Argue random walk, it goes as the square root of the nuber of connections:
[K]  =~  R[Lc]
# So...  maybe...  :-??
[E]  =~  [e]*(M3 + R[L2]*M2 + R[L2]*R[L1]*M1)
```

It's easy to forget that `W` can be either positive or negative.
I've had to double check my use of absolute values(`[]`) and
I think I caught them all.


[...AND MUCH MORE TODO:](TODO.md)
