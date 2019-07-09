local inspect = require 'lib.inspect'
local util = require 'util'

local function loadDna(filePath)
	local lines = {}
	-- read lines from a file, ignoring comments
	for line in love.filesystem.lines(filePath) do
		if line:sub(1, 2) ~= '>' then
			table.insert(lines, line)
		end
	end
	-- join the lines into one string
	local dnaString = table.concat(lines)
	-- pad the string with X's so its length is a multiple of 200
	for _ = 1, 200 - (#dnaString % 200) do
		dnaString = dnaString .. 'X'
	end
	return dnaString
end
