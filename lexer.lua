---@param str string
---@param pos? integer
function Lexer(str, pos)
    -- Instantly jump to the first non-whitespace character
    pos = str:find("%S", pos)
    if not pos then return nil, nil, nil end

    local first_char = str:sub(pos, pos)
    if first_char == ";" then
        error("syntax error: command starting with ';'")
    elseif first_char == "|" then
        error("syntax error: command starting with '|'")
    end

    local first_word = nil
    local words = {}
    local len = #str

    while pos do
        local char = str:sub(pos, pos)

        if char == ";" or char == "|" then
            return first_word, words, pos + 1, char
        end

        -- High-performance optimization: Use a table array as a string buffer
        local buf = {}
        local buf_idx = 1

        while pos <= len do
            char = str:sub(pos, pos)

            if char == " " or char == "\t" or char == ";" or char == "|" then
                break
            elseif char == '"' or char == "'" then
                local closing = str:find(char, pos + 1, true)
                if not closing then
                    error("syntax error: unclosed quote at " .. pos)
                end

                buf[buf_idx] = str:sub(pos + 1, closing - 1)
                buf_idx = buf_idx + 1
                pos = closing + 1
            else
                local next_delim = str:find("[%s;|\"']", pos)
                local end_pos = next_delim or (len + 1)
                local segment = str:sub(pos, end_pos - 1)

                if segment:sub(1, 2) == "\\$" then
                    segment = segment:sub(2)
                elseif segment:sub(1, 1) == "$" then
                    segment = posix.getenv(segment:sub(2)) or ''
                end

                buf[buf_idx] = segment
                buf_idx = buf_idx + 1
                pos = end_pos
            end
        end

        -- Concatenate the entire buffer all at once (extremely fast in C)
        local current_word = table.concat(buf)

        if not first_word then
            first_word = current_word
        else
            table.insert(words, current_word)
        end

        pos = str:find("%S", pos)
    end

    return first_word, words, nil, nil
end
