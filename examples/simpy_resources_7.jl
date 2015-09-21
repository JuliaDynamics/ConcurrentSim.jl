using SimJulia

type Mach
  size :: Int
  duration :: Float64
end

function user(env::Environment, name::Int, sto::Store, size::Int)
  machine = yield(Get(sto, (mach::Mach)->mach.size == size))
  println("$name got $machine at $(now(env))")
  yield(Timeout(env, machine.duration))
  yield(Put(sto, machine))
  println("$name released $machine at $(now(env))")
end

function machineshop(env::Environment, sto::Store)
  m1 = Mach(1, 2.0)
  m2 = Mach(2, 1.0)
  yield(Put(sto, m1))
  yield(Put(sto, m2))
end

env = Environment()
sto = Store{Mach}(env, 2)
ms = Process(env, machineshop, sto)
users = [Process(env, user, i, sto, (i % 2) +1) for i=0:2]
run(env)
