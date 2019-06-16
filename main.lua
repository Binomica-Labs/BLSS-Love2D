function create_thread()
  local thread = love.thread.newThread('multi2.lua')
  thread:start(1, 100000)
end



function love.load()
  love.window.setMode(1440, 900, {resizable=true, vsync=false, minwidth=400, minheight=300})
  loadedLines = {}
  initialNucleotides = {}

  for line in love.filesystem.lines("/SeqData/kleb.fna") do
    table.insert(loadedLines, line)
  end

  for i,z in ipairs(loadedLines) do
    if loadedLines[i]:find(">") == 1 then
      table.remove(loadedLines, i)
    end
  end

  loadedDNA = table.concat(loadedLines, "")
  loadedDNA = loadedDNA:gsub('[%p%c%s]', '')
  loadedDNA = loadedDNA:gsub('nil', '')

  --create_thread()
  text = ''
  --print(loadedDNA)
  loadedDNALength = string.len(loadedDNA)
  initialNucleotides = string.toTable(loadedDNA)
  if (loadedDNALength / 200) < 1 then
    loadedVisImageHeight = 1
  else
    loadedVisImageHeight = (loadedDNALength + (200 - (loadedDNALength % 200)))/ 200   --calculate how tall the visualization image will be rounded to the nearest factor of 200 for even display
    nucleotideRemainder = 200 - (loadedDNALength % 200)                               --calulate how much is remaining from the last row in the visualization image
    for i=1,nucleotideRemainder do
      table.insert(initialNucleotides, 'X')                                           --pad the remainder with the character X until the last row is filled to 200 pixels
    end
  end
  initialDNA = table.concat(initialNucleotides, "")
  initialVisualization = visualizeDNA(initialNucleotides)
  abstractedVisualization20 = visualizeDNA(abstractDNA(20))
  abstractedVisualization40 = visualizeDNA(abstractDNA(40))
  abstractedVisualization80 = visualizeDNA(abstractDNA(80))
  abstractedVisualization100 = visualizeDNA(abstractDNA(100))
  abstractedVisualization200 = visualizeDNA(abstractDNA(200))
  abstractedVisualization400 = visualizeDNA(abstractDNA(400))
end



function love.draw()
  --love.graphics.print('data is: ' .. text, 10, 10, 0, 1, 1)                     --an example output pulled from a dummy thread for later use
  love.graphics.draw(initialVisualization, 0, 0)                              --draw the first data vis column (1:1)
  love.graphics.draw(abstractedVisualization20, 205, 0)
  love.graphics.draw(abstractedVisualization40, 410, 0)
  love.graphics.draw(abstractedVisualization80, 615, 0)
  love.graphics.draw(abstractedVisualization100, 820, 0)
  love.graphics.draw(abstractedVisualization200, 1025, 0)
  love.graphics.draw(abstractedVisualization400, 1230, 0)

end



function love.update(dt)
  local data = love.thread.getChannel('data'):pop()                             --a dummy function to use later when pulling values from other threads
    if data then
      text = data
    end
  end



  function abstractDNA(abstractionLevel)
    choppedDNA = {}
    abstractedNucleotides = {}
    countA = 0
    countT = 0
    countC = 0
    countG = 0
    abstractionIterator = loadedDNALength / abstractionLevel                      --count how many fragments will be generated using the current abstraction level
    choppedDNA = splitByChunk(initialDNA, abstractionLevel)                       --chop the loaded and parsed DNA into equal chunks of abstractionLevel length

    for key,value in ipairs(choppedDNA) do                                        --for each fragment in the choppedDNA table

      currentFragment = choppedDNA[key]                                           --make the current fragment a variable to use
      _, countA = string.gsub(currentFragment, "A", "A")                          --Use the string substitution function's second output as a counter.
        _, countT = string.gsub(currentFragment, "T", "T")                          --Note the first variable is a dummy called _ (underscore) which would
        _, countC = string.gsub(currentFragment, "C", "C")                          --normally return a string containing the substitution. By substituting with the same
        _, countG = string.gsub(currentFragment, "G", "G")                          --character, you'll essentially just count how many times that char occurs.
        _, countX = string.gsub(currentFragment, "X", "X")

        if countA > countT and countA > countC and countA > countG and countA > countX then       --if A is the most common, fill with A
          choppedDNA[key] = string.rep("A", string.len(currentFragment))

        elseif countT > countA and countT > countC and countT > countG and countT > countX then    --if T is the most common, fill with T
          choppedDNA[key] = string.rep("T", string.len(currentFragment))

        elseif countC > countT and countC > countA and countC > countG and countC > countX then   --if C is the most common, fill with C
          choppedDNA[key] = string.rep("C", string.len(currentFragment))

        elseif countG > countT and countG > countA and countG > countC and countG > countX then   --if G is the most common, fill with G
          choppedDNA[key] = string.rep("G", string.len(currentFragment))

        elseif countX > countA and countX > countT and countX > countC and countX > countG then   --if X is the most common, fill with X
          choppedDNA[key] = string.rep("X", string.len(currentFragment))

        else if (countT + countA) > (countG + countC) then                          --if no majority but A+T larger than G+C then fill with A
          choppedDNA[key] = string.rep("A", string.len(currentFragment))

        elseif (countC + countG) > (countA + countT) then
          choppedDNA[key] = string.rep("G", string.len(currentFragment))            --if no majority but G+C larger than A+T then fill with G

          else
            choppedDNA[key] = string.rep("X", string.len(currentFragment))            --if all are equal, make it magenta because you can't really choose

          end
        end
      end

    abastractedDNA = table.concat(choppedDNA, "")
    abstractedNucleotides = string.toTable(abastractedDNA)
    return abstractedNucleotides
  end



    function visualizeDNA(nucleotides)
      local colorPosition = 1                                                       --this keeps track of the actual linear nucleotide count as it runs through the visualization image coords
      loadedVisData = love.image.newImageData(200, loadedVisImageHeight)            --initialize a new image of the correct size

      for visY=0, loadedVisImageHeight-1 do                                         --for every row...
        for visX=0, 199 do                                                          --for each pixel in the row...
          if nucleotides[colorPosition] == 'A' then
            loadedVisData:setPixel(visX, visY, 0, 0.8984375, 1, 1)                  --if A, set pixel color to Cyan, note color is from 0.000 to 1.000 which scales as 256 RGB ratio
            colorPosition = colorPosition + 1

          elseif nucleotides[colorPosition] == 'T' then
            loadedVisData:setPixel(visX, visY, 1, 1, 0, 1)                          --if T, set pixel color to Yelloy
            colorPosition = colorPosition + 1

          elseif nucleotides[colorPosition] == 'C' then
            loadedVisData:setPixel(visX, visY, 0.859375, 0, 0, 1)                   --if C, set pixel color to Red
            colorPosition = colorPosition + 1

          elseif nucleotides[colorPosition] == 'G' then
            loadedVisData:setPixel(visX, visY, 0, 0, 0, 1)                          --if G, set pixel color to Black
            colorPosition = colorPosition + 1
          else
            loadedVisData:setPixel(visX, visY, 1, 0, 1, 1)                          --else if any other letter including X set pixel to Magenta
              colorPosition = colorPosition + 1
            end
          end
        end
        local loadedVisImage = love.graphics.newImage(loadedVisData)
        return loadedVisImage
      end



      --function extensions
      function splitByChunk(textToSplit, chunkSize)
        local s = {}
        for i=1, #textToSplit, chunkSize do
          s[#s+1] = textToSplit:sub(i,i+chunkSize - 1)
        end
        return s
      end



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


      function string.toTable(string)
        local table = {}

        for i = 1, #string do
          table[i] = string:sub(i, i)
        end

        return table
      end
