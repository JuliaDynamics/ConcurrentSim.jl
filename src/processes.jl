type Process <: BaseEvent
  name :: ASCIIString
  task :: Task
  target :: Event
  ev :: Event
  function Process(name::ASCIIString, task::Task)
    proc = new()
    proc.name = name
    proc.task = task
    proc.ev = Event()
    return proc
  end
end
