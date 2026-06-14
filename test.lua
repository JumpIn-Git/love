local text = string.rep("word1 word2 word3 word4 word5 ", 10000) -- A very long string

-- --- METHOD 1: gmatch ---
local start1 = os.clock()
local count1 = 0
for word in text:gmatch("%S+") do
    count1 = count1 + 1
end
local time1 = os.clock() - start1

-- --- METHOD 2: Manual i, j Tracking ---
local start2 = os.clock()
local count2 = 0
local len = #text
local i = 1

while i <= len do
    -- Find the start of the next non-space block
    while i <= len and text:sub(i, i):match("%s") do
        i = i + 1
    end

    if i <= len then
        local j = i
        -- Find the end of the word
        while j <= len and not text:sub(j, j):match("%s") do
            j = j + 1
        end

        -- Extract the word
        local word = text:sub(i, j - 1)
        count2 = count2 + 1
        i = j
    end
end
local time2 = os.clock() - start2

print(string.format("gmatch time: %.4f seconds", time1))
print(string.format("Manual loop time: %.4f seconds", time2))
