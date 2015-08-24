using SimJulia

const SIM_DURATION = 100.0

type Cable
  env :: Environment
  delay :: Float64
  store :: Store{ASCIIString}
  function Cable(env::Environment, delay::Float64)
    cable = new()
    cable.env = env
    cable.delay = delay
    cable.store = Store{ASCIIString}(env)
    return cable
  end
end

function latency(env::Environment, cable::Cable, value::ASCIIString)
  yield(Timeout(env, cable.delay))
  yield(Put(cable.store, value))
end

function put(cable::Cable, value::ASCIIString)
  Process(cable.env, latency, cable, value)
end

function get(cable::Cable)
  return yield(Get(cable.store))
end

function sender(env::Environment, cable::Cable)
  while true
    yield(Timeout(env, 5.0))
    put(cable, "Sender send this at $(now(env))")
  end
end

function receiver(env::Environment, cable::Cable)
  while true
    msg = get(cable)
    println("Received this at $(now(env)) while $msg")
  end
end

println("Event latency")
env = Environment()

cable = Cable(env, 10.0)
Process(env, sender, cable)
Process(env, receiver, cable)

run(env, SIM_DURATION)
