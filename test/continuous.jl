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
  dx[1] = x[3]
  dx[3] = zero(t)
  dx[2] = x[4]
  dx[4] = -9.81 + p[1]*(2.0e4/0.1*(x[2]-(3.0-ceil(evaluate(x[1])/0.2)*0.2)))
end

@zerocrossing function contact(t, x, p, res)
  yf = 3.0 - ceil(x[1]/0.2)*0.2
  res = x[4] < 0.0 && x[2] - yf < 0.05
  if res
    p[1] = 1.0
  end
end

@zerocrossing function up(t, x, p, res)
  yf = 3.0 - ceil(x[1]/0.2)*0.2
  res = x[4] > 0.0 && x[2] - yf > 0.05
  if res
    p[1] = 0.0
  end
end

sim = Simulation()
cont = @continuous bouncing_ball(sim, [0.0, 3.05, 1.0, 0.0], [0.0])
@process report(sim, cont)
run(sim, 5)
