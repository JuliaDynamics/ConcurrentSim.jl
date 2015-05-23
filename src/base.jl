abstract BaseEvent
abstract BaseEnvironment

type EventKey
  time :: Float64
  priority :: Bool
  id :: Uint16
end

function isless(a::EventKey, b::EventKey)
	return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

function now(env::BaseEnvironment)
  return env.time
end
