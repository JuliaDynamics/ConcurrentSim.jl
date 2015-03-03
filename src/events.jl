type EventID
  time :: Float64
  priority :: Bool
  id :: Uint16
end

type Event
  callbacks :: Set
  id :: Uint16
  value
  function Event()
    ev = new()
    ev.callbacks = Set{Function}()
    return ev
  end
end

function isless(a::EventID, b::EventID)
	return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end
