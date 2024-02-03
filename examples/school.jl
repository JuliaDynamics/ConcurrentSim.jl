# based on example from
# https://simjuliajl.readthedocs.io/en/stable/topical_guides/3_events.html#example-usages-for-event
#

using ResumableFunctions
using ConcurrentSim

mutable struct School
  class_ends :: Event
  pupil_procs :: Vector{Process}
  bell_proc :: Process
  function School(env::Simulation)
    school = new()
    school.class_ends = Event(env)
    school.pupil_procs = Process[@process pupil(env, school) for i=1:3]
    school.bell_proc = @process bell(env, school)
    return school
  end
end

@resumable function bell(env::Simulation, school::School)
  for i=1:2
    @yield timeout(env, 45.0)
    succeed(school.class_ends)
    #school.class_ends = Event(env) -- ?? orig SimJulia example somehow works
    println()
  end
end

@resumable function pupil(env::Simulation, school::School)
  for i=1:2
    print(" \\o/")
    @yield school.class_ends
    school.class_ends = Event(env) # after yield event is idle
  end
end

env = Simulation()
school = School(env)
run(env)
