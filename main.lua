--BLSS Code Start
local inspect = require 'inspect'                                               --include library for easy debugging of table contents usage:  print(inspect(tableName)) output: really nice console read of contents of table regardless of data type
visCount = 1                                                                    --keeps track of visualization function iteration count. used to link file names from directory to the visualized dna output image.



  function love.load()                                                          --load things and call functions once as soon as app starts
    defineDirectoryTree()
        --create_thread()
        --text = ''                                                                 --initialize the text string variable tied to the dummy thread function, useless now, leaving for later use
  end



  function defineDirectoryTree()
    directoryPathTable = {}
    directoryNameTable = {}
    rootTable = love.filesystem.getDirectoryItems("SeqData/FoldersToVisualize") --enumerates all folders in the root/save directory of the app
    for key, value in ipairs(rootTable) do
      currentItemSelected = "SeqData/FoldersToVisualize/"..value
      if love.filesystem.getInfo(currentItemSelected, "directory") then
        table.insert(directoryPathTable, currentItemSelected)                   --save the full path of each directory as a string
        table.insert(directoryNameTable, value)                                 --save just the directory name (hopefully already as a genbank ID value) for later use as filename
      end
    end

    for tableKey, sequenceDirectory in ipairs(directoryPathTable) do
      fileName = sequenceDirectory.."/"..directoryNameTable[tableKey]..".fna"   --define the full file path by stitching the folder path and folder name (since genome fna file name MUST be identical to gneome FOLDER name)
      loadDNA(fileName)
    end
  end



  function BatchVisualization()
    --stuff
  end



  function loadDNA(dnaFilePath)
    loadedLines = {}                                                            --initiate loadedLines table which will store the lines of the DNA file. Note these are lines separated by an /n/r
    initialNucleotides = {}                                                     --initiate nucleotide table for storing the parsed DNA ready for further abstraction

    for line in love.filesystem.lines(dnaFilePath) do                           --read the Deinococcus radiophilus sample DNA file in the SeqData folder
      table.insert(loadedLines, line)                                           --for each line found, put it in the loadedLines table
    end

    for i,z in ipairs(loadedLines) do                                           --if a line starts with the FASTA delimiter >, get rid of it
      if loadedLines[i]:find(">") == 1 then
        table.remove(loadedLines, i)
      end
    end

    loadedDNA = table.concat(loadedLines, "")                                   --take all the remaining lines of just DNA and make it one big continuous string called loadedDNA
    loadedDNA = loadedDNA:gsub('[%p%c%s]', '')                                  --get rid of special characters
    loadedDNA = loadedDNA:gsub('nil', '')                                       --get rid of null characters, called nil in Lua
    loadedDNALength = string.len(loadedDNA)                                     --calculate the length of the entire DNA file after fasta comment removal
    initialNucleotides = string.toTable(loadedDNA)                              --chop the loadedDNA into single characters (nucleotides)
    if (loadedDNALength / 200) < 1 then                                         --if the dna file is less than one full row of pixels (200bp), make the visualization image height variable just 1 pixel tall
      loadedVisImageHeight = 1
    else
      loadedVisImageHeight = (loadedDNALength + (200 - (loadedDNALength % 200)))/ 200   --calculate how tall the visualization image will be rounded to the nearest factor of 200 for even display
      nucleotideRemainder = 200 - (loadedDNALength % 200)                       --calulate how much is remaining from the last row in the visualization image
      for i=1,nucleotideRemainder do
        table.insert(initialNucleotides, 'X')                                   --pad the remainder with the character X until the last row is filled to 200 pixels
      end
    end
    initialDNA = table.concat(initialNucleotides, "")                           --make one continuous string file of DNA adjusted with X's as padding to fit a string length that is cleanly divisible by the visualization column width, 200bp
    initialVisualization = visualizeDNA(initialNucleotides)                     --generate the first column of DNA visualization, one pixel per nucleotide
    abstractedVisualization20 = visualizeDNA(abstractDNA(20))                   --call the visualizeDNA function using DNA averaged to 20bp segments
      abstractedVisualization40 = visualizeDNA(abstractDNA(40))                 --abstraction to 40bp
      abstractedVisualization80 = visualizeDNA(abstractDNA(80))                 --abstraction to 80bp
      abstractedVisualization100 = visualizeDNA(abstractDNA(100))               --100bp
      abstractedVisualization200 = visualizeDNA(abstractDNA(200))               --200bp
      abstractedVisualization400 = visualizeDNA(abstractDNA(400))               --400bp
      canvas = love.graphics.newCanvas(1430, loadedVisImageHeight, { dpiscale = 1 })
      love.graphics.setCanvas(canvas)
      love.graphics.clear()
      love.graphics.draw(initialVisualization, 0, 0)                            --draw the first data vis column (1:1)
      love.graphics.draw(abstractedVisualization20, 205, 0)                     --draw the rest of the columns spaced by 5 pixels
      love.graphics.draw(abstractedVisualization40, 410, 0)                     --will make it a variable later, for now the distances are hardcoded
      love.graphics.draw(abstractedVisualization80, 615, 0)
      love.graphics.draw(abstractedVisualization100, 820, 0)
      love.graphics.draw(abstractedVisualization200, 1025, 0)
      love.graphics.draw(abstractedVisualization400, 1230, 0)
      love.graphics.setCanvas()

      love.filesystem.setIdentity("BLSS-Workspace/VisOutput")                   --changes the working directory to a subfolder in BLSS-Workspace called VisOutput
        savedDNAVis = canvas:newImageData()
        visName = directoryNameTable[visCount]..".png"                          --uses the file name of genomic DNA from dicectoryNameTable value and iterates using visCount integer variable
        tadaaa = savedDNAVis:encode("png", visName)
        visCount = visCount + 1
      love.filesystem.setIdentity("BLSS-Workspace")
    end



    function love.draw()
      love.graphics.draw(canvas)
      -- if love.keyboard.isDown("c") then
      --   love.graphics.clear()
      --   love.graphics.setColor(1, 1, 1, 1)
      --   savedDNAVis = canvas:newImageData()
      --   tadaaa = savedDNAVis:encode("png", "datavis.png")
      --
      -- else
      --   --love.graphics.print('data is: ' .. text, 10, 10, 0, 1, 1)          --an example output pulled from a dummy thread for later use
      --   --love.graphics.setColor(1, 1, 1, 1)
      --   --love.graphics.draw(canvas)
      -- end
    end



    function love.update(dt)
      if love.keyboard.isDown("escape") then
        love.event.quit()
      end
      --local data = love.thread.getChannel('data'):pop()                       --a dummy function to use later when pulling values from other threads
      --  if data then
      --    text = data
      --  end
    end



    function abstractDNA(abstractionLevel)                                      --this function finds the most dominant nucleotide in a given user-defined segment length of DNA
      choppedDNA = {}
      abstractedNucleotides = {}                                                --initialize the local tables and counting variables
      countA = 0
      countT = 0
      countC = 0
      countG = 0
      abstractionIterator = loadedDNALength / abstractionLevel                  --count how many fragments will be generated using the current abstraction level
      choppedDNA = splitByChunk(initialDNA, abstractionLevel)                   --chop the loaded and parsed DNA into equal chunks of abstractionLevel length

      for key,value in ipairs(choppedDNA) do                                    --for each fragment in the choppedDNA table

        currentFragment = choppedDNA[key]                                       --make the current fragment a variable to use
        _, countA = string.gsub(currentFragment, "A", "A")                      --Use the string substitution function's second output as a counter.
          _, countT = string.gsub(currentFragment, "T", "T")                    --Note the first variable is a dummy called _ (underscore) which would
          _, countC = string.gsub(currentFragment, "C", "C")                     --normally return a string containing the substitution. By substituting with the same
          _, countG = string.gsub(currentFragment, "G", "G")                    --character, you'll essentially just count how many times that char occurs.
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

          else if (countT + countA) > (countG + countC) then                    --if no majority but A+T larger than G+C then fill with A
            choppedDNA[key] = string.rep("A", string.len(currentFragment))

          elseif (countC + countG) > (countA + countT) then
            choppedDNA[key] = string.rep("G", string.len(currentFragment))      --if no majority but G+C larger than A+T then fill with G

            else
              choppedDNA[key] = string.rep("X", string.len(currentFragment))    --if all are equal, make it magenta because you can't really choose

            end
          end
        end

        abastractedDNA = table.concat(choppedDNA, "")                           --once all the abstractions are done, turn it into one long string by concatenating the DNA segments together with no spacer
        abstractedNucleotides = string.toTable(abastractedDNA)                  --make that long abstractDNA string into individual nucleotide characters
        return abstractedNucleotides                                            --function ends by returning the character table of nucleotides for feeding into the visualizeDNA function
        end



        function visualizeDNA(nucleotides)                                      --this function takes a character table as input and applies a pixel color on a 200 by x height image where each pixel is defined by the nucleotide type and image height is the total DNA file length rounded up to the nearest factor of the image width, 200 pixels
          local colorPosition = 1                                               --this keeps track of the actual linear nucleotide count as it runs through the visualization image coords
          loadedVisData = love.image.newImageData(200, loadedVisImageHeight)    --initialize a new image of the correct size

          for visY=0, loadedVisImageHeight-1 do                                 --for every row...
            for visX=0, 199 do                                                  --for each pixel in the row...
              if nucleotides[colorPosition] == 'A' then
                loadedVisData:setPixel(visX, visY, 0, 220/255, 255/255, 255/255)  --if A, set pixel color to Cyan, note color is from 0.000 to 1.000 which scales as 256 RGB ratio
                colorPosition = colorPosition + 1

              elseif nucleotides[colorPosition] == 'T' then
                loadedVisData:setPixel(visX, visY, 255/255, 255/255, 0, 255/255)  --if T, set pixel color to Yellow
                colorPosition = colorPosition + 1

              elseif nucleotides[colorPosition] == 'C' then
                loadedVisData:setPixel(visX, visY, 230/255, 0, 0, 255/255)      --if C, set pixel color to Red
                colorPosition = colorPosition + 1

              elseif nucleotides[colorPosition] == 'G' then
                loadedVisData:setPixel(visX, visY, 0, 0, 0, 255/255)            --if G, set pixel color to Black
                colorPosition = colorPosition + 1
              else
                loadedVisData:setPixel(visX, visY, 255/255, 0, 255/255, 255/255)  --else if any other letter including X set pixel to Magenta
                  colorPosition = colorPosition + 1
                end
              end
            end
            local loadedVisImage = love.graphics.newImage(loadedVisData)        --make an image file representing the visualized DNA
            return loadedVisImage                                               --function ends by returning the image generated in the previous line
            end



            --function create_thread()                                          --dummy thread function for later use
            --local thread = love.thread.newThread('threaddingExample.lua')                --calls a function stored on a different file, a really clean way to keep the main.lua file tidy
            --thread:start(1, 100000)
            --end



            --function extensions
            function splitByChunk(textToSplit, chunkSize)                       --custom function to split a string into equal chunks of user defined size
              local s = {}
              for i=1, #textToSplit, chunkSize do
                s[#s+1] = textToSplit:sub(i,i+chunkSize - 1)
              end
              return s
            end



            function string.explode(str, div)                                   --chop up string delimited by a certain character
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



            function string.toTable(string)                                     --turns a string into a character table directly and quickly
              local table = {}

              for i = 1, #string do
                table[i] = string:sub(i, i)
              end

              return table
            end
