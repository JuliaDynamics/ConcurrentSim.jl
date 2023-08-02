# Multi-server Queue
  
## Description

An [M/M/c queue](https://en.wikipedia.org/wiki/M/M/c_queue) is a basic queue with _c_ identical servers, exponentially distributed interarrival times, and exponentially distributed service times for each server. The arrival rate is defined as _λ_ such that the interarrival time distribution has mean _1/λ_. Similarly, the service rate is defined as _μ_ such that the service time distribution has mean _1/μ_ (for each server). The overall traffic intensity of the queue is _ρ = λ / (c * μ)_. If the traffic intensity exceeds one, the queue is unstable and the queue length will grow indefinitely. 

## Code

```julia
#set simulation parameters
Random.seed!(8710) # set random number seed for reproducibility
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
    @yield timeout(env, rand(d_s)) # server is busy
    @yield unlock(server) # customer exits service
    println("Customer $id exited service: ", now(env))
end

# setup and run simulation
sim = Simulation() # initialize simulation environment
server = Resource(sim, num_servers) # initialize servers
arrival_time = 0.0
for i = 1:num_customers # initialize customers
    arrival_time += rand(arrival_dist)
    @process customer(sim, server, i, arrival_time, service_dist)
end
run(sim) # run simulation

## output
#
# Customer 1 arrived: 0.1229193244813443
# Customer 1 entered service: 0.1229193244813443
# Customer 2 arrived: 0.22607641035584877
# Customer 2 entered service: 0.22607641035584877
# Customer 3 arrived: 0.4570009029409502
# Customer 2 exited service: 1.7657345101378559
# Customer 3 entered service: 1.7657345101378559
# Customer 1 exited service: 2.154824561031012
# Customer 3 exited service: 2.2765287086137764
# Customer 4 arrived: 2.3661687470062995
# Customer 4 entered service: 2.3661687470062995
# Customer 5 arrived: 2.6110816119637885
# Customer 5 entered service: 2.6110816119637885
# Customer 5 exited service: 2.8017888690417583
# Customer 6 arrived: 3.019540357955037
# Customer 6 entered service: 3.019540357955037
# Customer 6 exited service: 3.351151832298383
# Customer 7 arrived: 3.5254699872847612
# Customer 7 entered service: 3.5254699872847612
# Customer 7 exited service: 4.261422043181396
# Customer 4 exited service: 4.602071952938201
# Customer 8 arrived: 7.27536704811686
# Customer 8 entered service: 7.27536704811686
# Customer 9 arrived: 7.491176033637809
# Customer 9 entered service: 7.491176033637809
# Customer 10 arrived: 8.39098457094977
# Customer 8 exited service: 8.683396356977969
# Customer 10 entered service: 8.683396356977969
# Customer 9 exited service: 8.7501656586875
# Customer 10 exited service: 9.049670951561666
```
