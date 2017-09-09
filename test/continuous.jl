using SimJulia

@model function simple(t, x, p, dx)
  dx[1] = x[1]
end

#sim = Simulation()
#cont = @continuous simple(sim, [1.0]; stiff=false, order=4, Δrel=1e-16, Δabs=1e-6)
#run(sim, 10)

@model function diffeq(t, x, p, dx)
  dx[1] = p[2]+0.01*x[2]
  dx[2] = p[1]-100.0*x[1]-100.0*x[2]
end

function report(sim::Simulation, cont::SimJulia.Continuous)
  λ, P = eig([0.0 0.01; -100.0 -100.0])
  while true
    t = now(sim)
    xs = [evaluate(cont.vars[1]), evaluate(cont.vars[2])]
    xe = P*diagm(exp.(λ*t))*inv(P)*[0.0; 20.0]+P*diagm((exp.(λ*t)-1)./λ)*inv(P)*[0.0;2020.0]
    println(t, " ", xs[1], " ", abs(xe[1]-xs[1]), " ", xs[2], " ", abs(xe[2]-xs[2]))
    yield(Timeout(sim, 1.0))
  end
end

sim = Simulation()
cont = @continuous diffeq(sim, [0.0, 20.0], [2020.0, 0.0]; stiff=false, order=4, Δrel=1e-16, Δabs=1e-6)
@process report(sim, cont)
@time run(sim, 2000)

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

#sim = Simulation()
#cont = @continuous bouncing_ball(sim, [2.0, 0.0], [0.0])
#@process report(sim, cont)
#run(sim, 5)
