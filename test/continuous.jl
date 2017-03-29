using SimJulia

@model function diffeq(t, x, p, dq)
  dx[1] = 0.01*x[2]
  dx[2] = p[1]-100.0*x[1]-100.0*x[2]
end

@trigger function less_prey(t, x, p, res)
  res = x[1] < x[2]
  if res
    p[1] = 0.0
  end
end

sim = Simulation()
cont = @continuous diffeq(sim, [0.0, 20.0], [2020.0]; stiff=false, order=4)
zc = @zerocrossing less_prey(cont)
run(sim, 10.0)
for var in cont.vars
  println(var.x)
end
for q in cont.integrator.q
  println(q)
end
