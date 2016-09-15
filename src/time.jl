immutable SimulationPeriod <: Period
  value :: Float64
  function SimulationPeriod(value::Number=0)
    new(value)
  end
end

immutable SimulationInstant <: Dates.Instant
  periods :: SimulationPeriod
end

immutable SimulationTime <: TimeType
  instant :: SimulationInstant
end

function SimulationTime(value::Number=0)
  SimulationTime(SimulationInstant(SimulationPeriod(value)))
end

(==)(x::SimulationTime, y::SimulationTime) = x.instant.periods.value == y.instant.periods.value

function isless(t1::SimulationTime, t2::SimulationTime) :: Bool
  t1.instant.periods.value < t2.instant.periods.value
end

(+)(t::SimulationTime, p::SimulationPeriod)=SimulationTime(t.instant.periods.value + p.value)

function show(io::IO, t::SimulationTime)
  print(io, "$(t.instant.periods.value)")
end
