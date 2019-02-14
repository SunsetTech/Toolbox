local Package = {}

function Package.Clamp(Value,Low,High)
	return math.max(Low,math.min(Value,High))
end

function Package.InRange(Value,Low,High)
	return Low <= Value and Value <= High
end

function Package.RandomFloat(Low,High,Precision)
	return math.random(Low*(10^Precision),High*(10^Precision))/(10^Precision)
end

function Package.Closest(Value)
	if (Value < math.floor(Value) + 0.5) then
		return math.floor(Value)
	else
		return math.ceil(Value)
	end
end

function Package.Wrap(Value,Min,Max)
	local Stride = Max - Min
	if (Stride > 0) then
		Stride = Stride + 1
	elseif (Stride < 0) then
		Stride = Stride - 1
	end
	return ((Value - Min) % (Stride)) + Min
end

return Package