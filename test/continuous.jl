using SimJulia

@model function stiffeq(t, q, p, dq)
  dq[1] = 0.01*q[2]
  dq[2] = p[1]-100.0*q[1]-100.0*q[2]
end

sim = Simulation()
cont = @continuous stiffeq(sim, [0.0, 20.0], [2020.0]; order=6, stiff=true)
run(sim, 500.0)
