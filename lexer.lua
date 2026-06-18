-- Sample variable replacement function
local function replace_variable(var_name)
    return posix.getenv(var_name) or ''
end

---@param str string
---@param pos? integer
function lex(str, pos)
    -- Instantly jump to the first non-whitespace character
    pos = str:find("%S", pos)
    if not pos then return nil end

    if str:sub(pos, pos) == ";" then
        error("syntax error: command starting with ';'")
    end

    local first_word = nil
    local words = {}
    local len = #str

    while pos do
        local char = str:sub(pos, pos)

        if char == ";" then
            break
        elseif char == '"' or char == "'" then
            -- Find the matching closing quote instantly (true flag makes it a literal search)
            local closing = str:find(char, pos + 1, true)
            if not closing then
                error("syntax error: unclosed quote at " .. pos)
            end

            local word = str:sub(pos + 1, closing - 1)
            pos = closing + 1

            if not first_word then first_word = word else table.insert(words, word) end
        else
            -- Normal word: scan ahead for the next space, semicolon, or quote
            local next_delim = str:find("[%s;\"']", pos)
            local end_pos = next_delim or (len + 1)
            local word = str:sub(pos, end_pos - 1)
            pos = end_pos

            -- Check if the word starts with a variable token
            if word:sub(1, 2) == "\\$" then
                -- Strip the '\', leaving the '$' intact as a literal string
                word = word:sub(2)
            elseif word:sub(1, 1) == "$" then
                -- Process normal variable replacement
                word = replace_variable(word)
            end

            if not first_word then first_word = word else table.insert(words, word) end
        end

        -- Fast-forward straight to the next word, skipping all intermediate spaces
        pos = str:find("%S", pos)
    end

    return first_word, words, pos or (len + 1)
end

-- local test_cases = {
--     { name = "Valid Nested Quotes", input = 'greet "dfdf \'dffdf\'"' },
--     { name = "Valid Standalone Quotes", input = 'echo "dfd fdf"' },
--     { name = "Invalid: Starts with Semicolon", input = '; echo hello' },
--     { name = "Invalid: Unclosed Quote", input = 'echo "dfdf ffddfdf' },
--     { name = "Multi-line with Semicolon", input = 'say $name ; move $target' },
--     { name = "df", input = ' move \\$gij' },
--     { name = 'emoji', input = 'efef fefe 😭 df' }
-- }

-- for _, case in ipairs(test_cases) do
--     print("Testing Case: [" .. case.name .. "] -> Input: " .. case.input)

--     local pos = 1
--     local success, err

--     -- Loop through the input string
--     while pos and pos <= #case.input do
--         -- Use pcall to gracefully catch errors thrown by the lexer
--         success, err, case.rest, pos = pcall(lex, case.input, pos)

--         if not success then
--             print("  ✕ Error Caught: " .. err)
--             break
--         elseif err then -- 'err' variable acts as 'first_word' here on success
--             print("  ✓ Command: " .. err)
--             print("    Args: {" .. table.concat(case.rest, ", ") .. "}")
--         end
--     end
--     print("-------------------------------------------------------------")
-- end
