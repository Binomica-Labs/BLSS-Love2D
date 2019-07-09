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

local function getDominantBase(dnaString)
	local aCount = util.timesInString(dnaString, 'A')
	local tCount = util.timesInString(dnaString, 'T')
	local cCount = util.timesInString(dnaString, 'C')
	local gCount = util.timesInString(dnaString, 'G')
	local xCount = util.timesInString(dnaString, 'X')
	if aCount > tCount and aCount > cCount and aCount > gCount and aCount > xCount then
		return 'A'
	elseif tCount > aCount and tCount > cCount and tCount > gCount and tCount > xCount then
		return 'T'
	elseif cCount > tCount and cCount > aCount and cCount > gCount and cCount > xCount then
		return 'C'
	elseif gCount > tCount and gCount > aCount and gCount > cCount and gCount > xCount then
		return 'G'
	elseif xCount > aCount and xCount > tCount and xCount > cCount and xCount > gCount then
		return 'X'
	elseif (tCount + aCount) > (gCount + cCount) then
		return 'A'
	elseif (cCount + gCount) > (aCount + tCount) then
		return 'G'
	end
	return 'X'
end

local function abstractDna(dnaString, abstractionLevel)
	local dnaChunks = {}
	for i = 1, #dnaString, abstractionLevel do
		local chunk = dnaString:sub(i, i + abstractionLevel - 1)
		local dominantBase = getDominantBase(chunk)
		chunk = string.rep(dominantBase, abstractionLevel)
		table.insert(dnaChunks, chunk)
	end
	return table.concat(dnaChunks)
end

local dnaString = loadDna 'test-data/deino.fna'
local abstractedDna = abstractDna(dnaString, 100)

function love.draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. ' kb')
end
