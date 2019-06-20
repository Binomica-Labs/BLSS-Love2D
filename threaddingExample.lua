--functional example of cross-thread communication

local start, ending = ...

for i=start, ending do
love.thread.getChannel('data'):push(i*i)
end
