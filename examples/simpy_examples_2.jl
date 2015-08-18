using SimJulia
using Distributions
using Compat


const RANDOM_SEED = 158
const TICKETS = 50  # Number of tickets per movie
const SIM_TIME = 120.0  # Simulate until

# Create movie theater
type Theater
  movies :: Vector{ASCIIString}
  counter :: Resource
  available :: Dict{ASCIIString, Int64}
  sold_out :: Dict{ASCIIString, Event}
  when_sold_out :: Dict{ASCIIString, Float64}
  num_renegers :: Dict{ASCIIString, Int64}
  function Theater(env)
    theater = new()
    theater.movies = ASCIIString["Julia Unchained", "Kill Process", "Pulp Implementation"]
    theater.counter = Resource(env, 1)
    theater.available = @compat Dict("Julia Unchained" => TICKETS, "Kill Process" => TICKETS, "Pulp Implementation" => TICKETS)
    theater.sold_out = @compat Dict("Julia Unchained" => Event(env), "Kill Process" => Event(env), "Pulp Implementation" => Event(env))
    theater.when_sold_out = @compat Dict("Julia Unchained" => typemax(Float64), "Kill Process" => typemax(Float64), "Pulp Implementation" => typemax(Float64))
    theater.num_renegers = @compat Dict("Julia Unchained" => 0, "Kill Process" => 0, "Pulp Implementation" => 0)
    return theater
  end
end

function moviegoer(env::Environment, movie::ASCIIString, num_tickets::Int64, theater::Theater)
  req = Request(theater.counter)
  result = yield(req | theater.sold_out[movie])
  if in(theater.sold_out[movie], keys(result))
    theater.num_renegers[movie] += 1
    cancel(theater.counter, req)
  elseif theater.available[movie] < num_tickets
    yield(Timeout(env, 0.5))
    yield(Release(theater.counter))
  else
    theater.available[movie] -= num_tickets
    if theater.available[movie] < 2
      succeed(theater.sold_out[movie])
      theater.when_sold_out[movie] = now(env)
      theater.available[movie] = 0
    end
    yield(Timeout(env, 1.0))
    yield(Release(theater.counter))
  end
end

function customer_arrivals(env::Environment, theater::Theater)
  t = Exponential(0.5)
  d = DiscreteUniform(1, 3)
  n = DiscreteUniform(1, 6)
  while true
    yield(Timeout(env, rand(t)))
    movie = theater.movies[rand(d)]
    num_tickets = rand(n)
    if theater.available[movie] > 0
      Process(env, moviegoer, movie, num_tickets, theater)
    end
  end
end

# Setup and start the simulation
println("Movie renege")
srand(RANDOM_SEED)
env = Environment()
theater = Theater(env)

# Start process and run
Process(env, customer_arrivals, theater)
run(env, SIM_TIME)

# Analysis/results
for movie in theater.movies
  if processed(theater.sold_out[movie])
    println("Movie $movie sold out $(theater.when_sold_out[movie]) minutes after ticket counter opening.")
    println("  Number of people leaving queue when film sold out: $(theater.num_renegers[movie])")
  end
end
