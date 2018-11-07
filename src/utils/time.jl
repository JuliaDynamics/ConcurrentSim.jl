function Simulation(initial_time::DateTime)
  Simulation(Base.Dates.datetime2epochms(initial_time))
end

function run(env::Environment, until::DateTime)
  run(env, Base.Dates.datetime2epochms(until))
end

function timeout(env::Environment, delay::Period; priority::Int=0, value::Any=nothing)
  time = now(env)
  del = Base.Dates.datetime2epochms(Base.Dates.epochms2datetime(time)+delay)-time
  timeout(env, del; priority=priority, value=value)
end

function nowDatetime(env::Environment)
  Base.Dates.epochms2datetime(now(env))
end
