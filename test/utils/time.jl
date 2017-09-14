using SimJulia
using Base.Dates

function datetimetest(sim::Simulation)
  println(nowDatetime(sim))
  yield(Timeout(sim, Day(2)))
  println(nowDatetime(sim))
end

datetime = now()
sim = Simulation(datetime)
@oldprocess datetimetest(sim)
run(sim, datetime+Month(3))
println(nowDatetime(sim))
