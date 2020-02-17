# Scratch area

Test area for "learning factor".

# Test runs

[Tabulated results](RUNS.md)

## Help

```console
$ ./scratch/test_runs  -h
Usage:
  test_runs [:options+] <file> <number=NUMBER>
Options:
  --max=NUMBER
  --show
  --div
Types:
  NUMBER   /^\d+(.d+)?$/
```

## Sample run

```console
$ ./scratch/test_runs --max=100000 f6eee6 27
........
Hits: 4  Time: 13.1  Count: 16536
...
Hits: 4  Time: 5.3  Count: 6800
..
Hits: 4  Time: 4.2  Count: 5124
...............
Hits: 4  Time: 24.7  Count: 31780
.................
Hits: 4  Time: 26.6  Count: 34058
...
Hits: 4  Time: 5.7  Count: 7209
..
Hits: 4  Time: 3.5  Count: 4384
......
Hits: 4  Time: 9.7  Count: 12444
.....................
Hits: 4  Time: 34.4  Count: 43985
....
Hits: 4  Time: 7.6  Count: 9131
...
Hits: 4  Time: 4.8  Count: 6014
......
Hits: 4  Time: 10.4  Count: 12973
## TOTALS scratch/0f6eee6.rb 27.0 ###
Hits: 48  Time: 150.0  Count: 190438  Fails: 0
444444444444
```

# Cycles per second

* Calculated for the best performing run

## Sorted by CPS

| File    | Count  | Time  | CPS  |
|:--------|-------:|------:|-----:|
| 6.1.0   | 320966 | 171.6 | 1870 |
|learning | 253175 | 193.7 | 1307 |
| mues    | 262699 | 209.2 | 1256 |
| 0f6eee6 | 190438 | 159.4 | 1195 |
| 1krm    | 357344 | 300.9 | 1188 |
| muk     | 174684 | 172.5 | 1013 |

## Sorted by time

| File    | Count  | Time  | CPS  |
|:--------|-------:|------:|-----:|
| 0f6eee6 | 190438 | 159.4 | 1195 |
| muk     | 174684 | 172.5 | 1013 |
| 6.1.0   | 320966 | 189.9 | 1690 |
|learning | 253175 | 193.7 | 1307 |
| mues    | 262699 | 209.2 | 1256 |
| 1krm    | 357344 | 300.9 | 1188 |

## Sorted by cycles

| File    | Count  | Time  | CPS  |
|:--------|-------:|------:|-----:|
| muk     | 174684 | 172.5 | 1013 |
| 0f6eee6 | 190438 | 159.4 | 1195 |
|learning | 253175 | 193.7 | 1307 |
| mues    | 262699 | 209.2 | 1256 |
| 6.1.0   | 320966 | 189.9 | 1690 |
| 1krm    | 357344 | 300.9 | 1188 |


# Learning factor formulas

I assume the learning factor has the form:
```ruby
learning = 1.0 / (Math.sqrt(number) * mue)
```
where `number` is a user specified tunning for the network.
The pseudo code for the different methods used to determine `mue`
uses  the following definitions in common:
```ruby
R  ==  Math.sqrt
M  ==  1 + {connection, connection.node.activation}
# In FF, all nodes in a layer have the same mue:
Mi  ==  layers[i].first.mue
Li  ==  layers[i].length
a^b  ==  a**b
```
And it's always a good idea to double check the code in the file.
:smile:

## learning

Keeps it simple:
```ruby
mue  ==  R[number]
```
The best "standard runs" where in with `number` in (73^2, 81^2)
with cycles in (253K, 317K) and 1 failure.

## 6.1.0

In version six, I'm claiming to be counting the number of biases and weights.
But I got the starting and ending wrong.
I start by counting the number of nodes in entrada...
which has no biases, and skip the count of the neurons in salida.
Basically, it's confused.
But because most FFs are square, this mosltly comes out OK.
Anyways, NeoYinYang, the FF I'm using in these tests, is square,
and so the mistake does not matter.
```ruby
# 6.01. is:
mue  ==  R[number] * (1 + (0...N){i, L[i-1] + L[i-1]*Li})
# But should have been(as claimed):
mue  ==  R[number] * (1 + (1...N){i, Li + Li*L[i-1])})
```
The best "standard run" was with `number` 2
with 321K cycles and 1 failure.

## mues

```ruby
mue  ==  R[number] * {i, Mi}
```
The best "standard run" was with `number` 7^2
with 263K cycles and 1 failure.

## 0f6eee6

Git version 0f6eee6...,
mue is calculated for each neuron.
The idea is to split the error equally among the layers,
followed by an additional amount due to the neuron's M value.
```ruby
mue  ==  R[number] * (N-1) * M   # M calculated for each neuron
```
The best "standard run" was with `number` 27(~5.2^2)
with 190K cycles and no failures.

## muk

Muk uses recursion to add up all the weighted error contributions.
```ruby
MUK  ==  1 + {A + A*(1-A)*MUK}
mue  ==  R[number] * MUK
```
The best "standard run" was with `number` 32(~5.66^2)
with 175K cycles and 1 failure.

## 1krm

1krm attempts to calculate mue from averages of the network.
```ruby
# Ack is the activation of the connected neuron(c is typically i-1).
KAPPA[i,j]  ==  {k, Dijk*Wijk}  ==  {k, Ack*(1-Ack)*Wijk}
# Total number of neurons
NU  ==  {i, Li}
# Root mean squares of kappas
KAPPA  ==  R[{(i,j), KAPPA[i,j]^2}/NU]
# Root mean square of layer lengths
RHO  ==  R[{i, Li^2}/N]
mue  ==  R[number] * {i, Mi*(1 + KAPPA*RHO)}
```
The best "standard run" was with `number` 3^2
with 357K cycles and 1 failure.

