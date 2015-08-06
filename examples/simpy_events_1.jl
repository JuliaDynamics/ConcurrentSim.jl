using SimJulia

function my_callback(event::Event)
  println("Called back from $event")
end

env = Environment()
event = Event(env)
append_callback(event, my_callback)
succeed(event)
run(env)
