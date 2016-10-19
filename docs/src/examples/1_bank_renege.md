# Bank Renege

Covers:

- Resources
- Event operators

A counter with a random service time and customers who renege.

This example models a bank counter and customers arriving at random times. Each customer has a certain patience. It waits to get to the counter until she’s at the end of her tether. If she gets to the counter, she uses it for a while.

New customers are created by the source process every few time steps.

```@eval
Markdown.Code("julia", readstring(joinpath("..", "..", "..", "examples", "examples", "1_bank_renege.jl")))
```
```@example
include(joinpath("..", "examples", "examples", "1_bank_renege.jl")) # hide
```
