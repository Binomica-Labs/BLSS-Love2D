function love.load(arg)
  CDSs = {}
  codons = {}

  for line in love.filesystem.lines("/SeqData/deinorna.txt") do
    table.insert(CDSs, line)
  end

  for i,z in ipairs(CDSs) do
    if CDSs[i]:find(">") == 0 and CDSs[i]:find("protein=hypothetical protein") == 0 then
      table.remove(CDSs, i)
    else
      table.remove(CDSs, i)
      table.remove(CDSs, i+1)
    end
  end
end



function love.update(dt)
--stuff i guess
end



function love.draw()
  for i,z in ipairs(CDSs) do
    love.graphics.printf(CDSs[i], 0, (love.graphics.getHeight()/2) + i*10 , love.graphics.getWidth(), "left")
  end
end



--string functions
function string.explode(str, div)
  assert(type(str) == "string" and type(div) == "string", "invalid arguments")
  local o = {}
  while true do
    local pos1,pos2 = str:find(div)
    if not pos1 then
      o[#o+1] = str
      break
    end
    o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
  end
  return o
end
