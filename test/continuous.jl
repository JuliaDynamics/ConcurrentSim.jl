using SimJulia

@model function diffeq(t, x, p, dx)
  dx[1] = 0.01*x[2]
  dx[2] = p[1]-100.0*x[1]-100.0*x[2]
end

function report(sim::Simulation, cont::Continuous)
  while true
    println(now(sim), " ", evaluate(cont.vars[1]), " ", evaluate(cont.vars[2]))
    yield(Timeout(sim, 1.0))
  end
end

sim = Simulation()
cont = @continuous diffeq(sim, [0.0, 20.0], [2020.0]; stiff=false, order=4)
@process report(sim, cont)
run(sim, 71)

@model function bouncing_ball(t, x, p, dx)
  g = 9.81
  m = 1.0
  b = 30.0
  k = 1.0e6
  if x[1] < 0.0
    p[1] = 1.0
  else
    p[1] = 0.0
  end
  f = k*x[1] + b*x[2]
  dx[1] = x[2]
  dx[2] = -g - p[1]*f/m
end

sim = Simulation()
cont = @continuous bouncing_ball(sim, [2.0, 0.0], [0.0])
@process report(sim, cont)
run(sim, 5)
