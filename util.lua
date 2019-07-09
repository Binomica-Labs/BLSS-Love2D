local util = {}

--https://github.com/rxi/lume/blob/master/lume.lua#L87
function util.round(x, increment)
	if increment then return util.round(x / increment) * increment end
	return x >= 0 and math.floor(x + .5) or math.ceil(x - .5)
end

return util
