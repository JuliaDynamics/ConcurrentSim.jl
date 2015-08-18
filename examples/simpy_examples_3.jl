using SimJulia
using Distributions

const RANDOM_SEED = 23062015
const PT_MEAN = 10.0         # Avg. processing time in minutes
const PT_SIGMA = 2.0         # Sigma of processing time
const MTTF = 300.0           # Mean time to failure in minutes
const REPAIR_TIME = 30.0     # Time it takes to repair a machine in minutes
const JOB_DURATION = 30.0    # Duration of other jobs in minutes
const NUM_MACHINES = 10      # Number of machines in the machine shop
const WEEKS = 4              # Simulation time in weeks
const SIM_TIME = WEEKS * 7 * 24 * 60.0  # Simulation time in minutes

type Machine
  name :: ASCIIString
  parts_made :: Int64
  broken :: Bool
  proc :: Process
  function Machine(env::Environment, name::ASCIIString, repairman::Resource)
    mach = new()
    mach.name = name
    mach.parts_made = 0
    mach.broken = false
    mach.proc = Process(env, name, working, mach, repairman)
    Process(env, break_machine, mach)
    return mach
  end
end

function working(env::Environment, mach::Machine, repairman::Resource)
  d = Normal(PT_MEAN, PT_SIGMA)
  while true
    done_in = abs(rand(d))
    while done_in > 0.0
      start = now(env)
      try
        yield(Timeout(env, done_in))
        done_in = 0.0
      catch(interrupted)
        mach.broken = true
        done_in -= now(env) - start
        yield(Request(repairman, 1, true))
        yield(Timeout(env, REPAIR_TIME))
        yield(Release(repairman))
        mach.broken = false
      end
    end
    mach.parts_made += 1
  end
end

function break_machine(env::Environment, mach::Machine)
  d = Exponential(MTTF)
  while true
    yield(Timeout(env, rand(d)))
    if !mach.broken
      yield(Interruption(mach.proc))
    end
  end
end

function other_jobs(env::Environment, repairman::Resource)
  while true
    done_in = JOB_DURATION
    while done_in > 0.0
      yield(Request(repairman, 2, false))
      start = now(env)
      try
        yield(Timeout(env, done_in))
        done_in = 0.0
        yield(Release(repairman))
      catch(preempted)
        done_in -= now(env) - start
      end
    end
  end
end

# Setup and start the simulation
println("Machine shop")
srand(RANDOM_SEED)

# Create an environment and start the setup process
env = Environment()
repairman = Resource(env, 1)
machines = [Machine(env, "Machine $i", repairman) for i = 1:NUM_MACHINES]
Process(env, other_jobs, repairman)

# Execute!
run(env, SIM_TIME)

# Analyis/results
println("Machine shop results after $WEEKS weeks")
for machine in machines
  println("$(machine.name) made $(machine.parts_made) parts.")
end
