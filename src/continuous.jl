type Variable
	value :: Float64
	old_value :: Float64
	rate :: Float64
end

type Continuous
	derivatives :: Function
end

