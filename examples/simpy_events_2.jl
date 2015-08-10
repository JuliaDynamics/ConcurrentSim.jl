using SimJulia

type School
  class_ends :: Event
  pupil_procs :: Vector{Process}
  bell_proc :: Process
  function School(env::Environment)
    school = new()
    school.class_ends = Event(env)
    school.pupil_procs = Process[Process(env, pupil, school) for i=1:3]
    school.bell_proc = Process(env, bell, school)
    return school
  end
end

function bell(env::Environment, school::School)
  for i=1:2
    yield(Timeout(env, 45.0))
    succeed(school.class_ends)
    school.class_ends = Event(env)
    println()
  end
end

function pupil(env::Environment, school::School)
  for i=1:2
    print(" \\o/")
    yield(school.class_ends)
  end
end

env = Environment()
school = School(env)
run(env)
