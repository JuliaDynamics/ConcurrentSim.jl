function advance_time(var::Variable, t::Float64)
  x = var.x
  Δt = t - var.t
  var.x = evaluate(x, Δt + Taylor1(x.order))
  var.t = t
  var.x.coeffs[1]
end

function advance_time(integrator::QSS, i::Int, t::Float64)
  q = integrator.q[i]
  Δt = t - integrator.t[i]
  integrator.q[i] = evaluate(q, Δt + Taylor1(q.order))
  integrator.t[i] = t
  integrator.q[i].coeffs[1]
end
