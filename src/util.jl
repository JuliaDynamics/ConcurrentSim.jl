function starter(env::BaseEnvironment, delay::Float64, func::Function, args...)
  yield(timeout(env, delay))
  return Process(env, func, args...)
end

function start_delayed(env::BaseEnvironment, delay::Float64, func::Function, args...)
  return Process(env, starter, delay, func, args...)
end