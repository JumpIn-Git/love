_G.posix = require 'posix'
_G.argparse = require 'argparse'
RL = require 'readline'
RL.set_readline_name(Name)
Child = 0

function MergeT(t1, t2)
    local t = require 'table.new' (#t1 + #t2, 0)
    for i = 1, #t1 do
        t[i] = t1[i]
    end
    for i = 1, #t2 do
        t[i + #t1] = t2[i]
    end
    return t
end

function ExpandTilde(s)
    if s:sub(1, 1) == '~' then
        return State.home .. s:sub(2)
    end
    return s
end

function _exit(msg, status)
    print(msg)
    posix._exit(status)
end

function CallParseNoExit(parser, args)
    local ok, res = parser:pparse(args)
    if not ok then
        io.stderr:write(("%s\n\nError: %s\n"):format(parser:get_usage(), res))
    end
    return ok, res
end

function Run(program, args, aliased, pipe)
    if Builtins[program] then
        State.status = Builtins[program](args) or 0
        return
    end
    if (not aliased) and State.alias[program] then
        args = MergeT(State.alias[program][2], args)
        program = State.alias[program][1]
        Run(program, args, true)
        return
    end

    local pid, err = posix.fork()
    if not pid then
        io.stderr:write(Name .. ': fork failed: ' .. (err or 'unknown error') .. '\n')
    elseif pid == Child then
        posix.signal(posix.SIGINT, "SIG_DFL")
        local _, err, code = posix.execp(program, args)
        io.stderr:write(Name .. ': ' .. err .. '\n') -- We only reach this point if program didn't replace child
        posix._exit(code)
    else
        local old_handler = posix.signal(posix.SIGINT, "SIG_IGN")
        local pid, reason, status = posix.wait(pid)
        posix.signal(posix.SIGINT, old_handler)

        if not pid then
            State.status = 1
        elseif reason == 'exited' then
            State.status = status
        elseif reason == 'killed' then
            State.status = status + 128
            if status == posix.SIGINT then
                io.write('\n')
            end
        else
            State.status = 1
        end
    end
end

function RunPipeline(pipeline)
    local n = #pipeline
    local pipes = {}
    local children = {}

    for i = 1, n - 1 do
        local rd, wr = posix.pipe()
        if not rd then
            io.stderr:write(Name .. ': pipe failed\n')
            return
        end
        pipes[i] = { rd = rd, wr = wr }
    end

    for i, cmd in ipairs(pipeline) do
        local program, args = cmd[1], cmd[2]

        if State.alias[program] then
            args = MergeT(State.alias[program][2], args)
            program = State.alias[program][1]
        end

        local pid, err = posix.fork()
        if not pid then
            io.stderr:write(Name .. ': fork failed: ' .. (err or 'unknown error') .. '\n')
            return
        elseif pid == Child then
            posix.signal(posix.SIGINT, "SIG_DFL")

            if i > 1 then
                posix.dup2(pipes[i - 1].rd, 0)
            end
            if i < n then
                posix.dup2(pipes[i].wr, 1)
            end

            for _, p in ipairs(pipes) do
                posix.close(p.rd)
                posix.close(p.wr)
            end

            if Builtins[program] then
                io.stderr:write(Name .. ': builtin in pipeline not supported: ' .. program .. '\n')
                posix._exit(1)
            end

            local _, err, code = posix.execp(program, args)
            io.stderr:write(Name .. ': ' .. err .. '\n')
            posix._exit(code)
        else
            children[i] = pid
        end
    end

    for _, p in ipairs(pipes) do
        posix.close(p.rd)
        posix.close(p.wr)
    end

    -- local old_handler = posix.signal(posix.SIGINT, "SIG_IGN")
    for i = 1, n do
        local pid, reason, status = posix.wait(children[i])
        if i == n then
            if not pid then
                State.status = 1
            elseif reason == 'exited' then
                State.status = status
            elseif reason == 'killed' then
                State.status = status + 128
                if status == posix.SIGINT then
                    io.write('\n')
                end
            else
                State.status = 1
            end
        end
    end
    -- posix.signal(posix.SIGINT, old_handler)
end

function SetPrompt()
    -- Define ANSI color codes
    local cyan  = "\27[36m"
    local green = "\27[32m"
    local white = "\27[37m"
    local reset = "\27[0m"

    if State.cwd == State.home then
        State.prompt = green .. "$ " .. reset
    else
        State.prompt = cyan .. State.cwd .. green .. " $ " .. reset
    end
end
