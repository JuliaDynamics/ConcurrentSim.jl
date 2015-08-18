function starter(env::AbstractEnvironment, delay::Float64, func::Function, args...)
  yield(Timeout(env, delay))
  return Process(env, func, args...)
end

function DelayedProcess(env::AbstractEnvironment, delay::Float64, func::Function, args...)
  return Process(env, starter, delay, func, args...)
end
