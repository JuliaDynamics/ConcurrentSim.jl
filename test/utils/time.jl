using SimJulia
using Dates

@resumable function datetimetest(sim::Simulation)
  println(nowDatetime(sim))
  @yield timeout(sim, Day(2))
  println(nowDatetime(sim))
end

datetime = now()
sim = Simulation(datetime)
@process datetimetest(sim)
run(sim, datetime+Month(3))
println(nowDatetime(sim))
