function Simulation(initial_time::DateTime)
  Simulation(Dates.datetime2epochms(initial_time))
end

function run(env::Environment, until::DateTime)
  run(env, Dates.datetime2epochms(until))
end

function timeout(env::Environment, delay::Period; priority=0, value=nothing)
  time = now(env)
  del = Dates.datetime2epochms(Dates.epochms2datetime(time)+delay)-time
  timeout(env, del; priority=Int(priority), value)
end

function nowDatetime(env::Environment)
  Dates.epochms2datetime(now(env))
end
