using SimJulia
using Distributions

const RUNS = 100
const N = 10
const S = 3
const SEED = 150
const LAMBDA = 100
const MU = 1

function work(env::Environment, repair_facility::Resource, spares::Store{Process})
  dist_work = Exponential(LAMBDA)
  dist_repair = Exponential(MU)
  while true
    try
      yield(Timeout(env, Inf))
    catch(exc)
    end
    println("At time $(now(env)): $(active_process(env)) starts working.")
    yield(Timeout(env, rand(dist_work)))
    println("At time $(now(env)): $(active_process(env)) stops working.")
    get_spare = Get(spares)
    res = yield(get_spare | Timeout(env, 0.0))
    if in(get_spare, keys(res))
      yield(Interrupt(res[get_spare]))
    else
      stop_simulation(env)
    end
    yield(Request(repair_facility))
    println("At time $(now(env)): $(active_process(env)) repair starts.")
    yield(Timeout(env, rand(dist_repair)))
    yield(Release(repair_facility))
    println("At time $(now(env)): $(active_process(env)) is repaired.")
    yield(Put(spares, active_process(env)))
  end
end

function start_sim(env::Environment, repair_facility::Resource, spares::Store{Process})
  procs = Process[]
  for i=1:N
    push!(procs, Process(env, "Machine $i", work, repair_facility, spares))
  end
  yield(Timeout(env, 0.0))
  for proc in procs
    yield(Interrupt(proc))
  end
  for i=1:S
    yield(Put(spares, Process(env, "Machine $(i+10)", work, repair_facility, spares)))
  end
end

function sim_repair()
  env = Environment()
  repair_facility = Resource(env)
  spares = Store{Process}(env)
  Process(env, start_sim, repair_facility, spares)
  run(env)
  now(env)
end

srand(SEED)
results = Float64[]
for i=1:RUNS
  push!(results, sim_repair())
end
println(sum(results)/RUNS)
