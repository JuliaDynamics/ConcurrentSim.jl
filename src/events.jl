abstract BaseEvent

type NoneEvent <: BaseEvent end

type EventID
  time :: Float64
  priority :: Bool
  id :: Uint16
end

type Event <: BaseEvent
  callbacks :: Set{(Function, BaseEvent)}
  id :: Uint16
  value
  function Event()
    ev = new()
    ev.callbacks = Set{(Function, BaseEvent)}()
    return ev
  end
end

function isless(a::EventID, b::EventID)
	return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

function triggered(ev::Event)
  return isdefined(ev, :value) && !isdefined(ev, :id)
end

function processed(ev::Event)
  return isdefined(ev, :id)
end

function push!(ev::Event, callback::Function)
  push!(ev.callbacks, (callback, NoneEvent()))
end
