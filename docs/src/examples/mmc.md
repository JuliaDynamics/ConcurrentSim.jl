# Multi-server Queue
  
## Description

An [M/M/c queue](https://en.wikipedia.org/wiki/M/M/c_queue) is a basic queue with _c_ identical servers, exponentially distributed interarrival times, and exponentially distributed service times for each server. The arrival rate is defined as _λ_ such that the interarrival time distribution has mean _1/λ_. Similarly, the service rate is defined as _μ_ such that the service time distribution has mean _1/μ_ (for each server). The overall traffic intensity of the queue is _ρ = λ / (c * μ)_. If the traffic intensity exceeds one, the queue is unstable and the queue length will grow indefinitely. 

## Code

```jldoctest
using StableRNGs
using Distributions
using ConcurrentSim
using ResumableFunctions

#set simulation parameters
rng = StableRNG(123)
num_customers = 10 # total number of customers generated

# set queue parameters
num_servers = 2 # number of servers
mu = 1.0 / 2 # service rate
lam = 0.9 # arrival rate
arrival_dist = Exponential(1 / lam) # interarrival time distriubtion
service_dist = Exponential(1 / mu) # service time distribution

# define customer behavior
@resumable function customer(env::Environment, server::Resource, id::Integer, t_a::Float64, d_s::Distribution)
    @yield timeout(env, t_a) # customer arrives
    println("Customer $id arrived: ", now(env))
    @yield request(server) # customer starts service
    println("Customer $id entered service: ", now(env))
    @yield timeout(env, rand(rng,d_s)) # server is busy
    @yield unlock(server) # customer exits service
    println("Customer $id exited service: ", now(env))
end

# setup and run simulation
function setup_and_run()
    sim = Simulation() # initialize simulation environment
    server = Resource(sim, num_servers) # initialize servers
    arrival_time = 0.0
    for i = 1:num_customers # initialize customers
        arrival_time += rand(rng,arrival_dist)
        @process customer(sim, server, i, arrival_time, service_dist)
    end
    run(sim) # run simulation
end
setup_and_run()

# output
Customer 1 arrived: 0.14518451436852475
Customer 1 entered service: 0.14518451436852475
Customer 2 arrived: 0.5941831542903504
Customer 2 entered service: 0.5941831542903504
Customer 3 arrived: 1.5490648267819074
Customer 4 arrived: 1.6242796925312217
Customer 5 arrived: 1.6911000709069648
Customer 1 exited service: 2.200985520126681
Customer 3 entered service: 2.200985520126681
Customer 6 arrived: 2.2989039524296317
Customer 3 exited service: 3.5822120399442174
Customer 4 entered service: 3.5822120399442174
Customer 7 arrived: 4.377930221620456
Customer 8 arrived: 5.16494279700802
Customer 2 exited service: 5.900722829377648
Customer 5 entered service: 5.900722829377648
Customer 9 arrived: 7.0099944106308705
Customer 10 arrived: 7.828990220943469
Customer 5 exited service: 9.634196437885254
Customer 6 entered service: 9.634196437885254
Customer 4 exited service: 9.670688398447817
Customer 7 entered service: 9.670688398447817
Customer 7 exited service: 15.066978111608014
Customer 8 entered service: 15.066978111608014
Customer 8 exited service: 16.655548432659554
Customer 9 entered service: 16.655548432659554
Customer 6 exited service: 17.401833154870328
Customer 10 entered service: 17.401833154870328
Customer 9 exited service: 17.586065352135993
Customer 10 exited service: 18.690264775280085
```
