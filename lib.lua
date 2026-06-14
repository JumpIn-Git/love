_G.posix = require 'posix'
_G.argparse = require 'argparse'
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

function Run(program, args, aliased)
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

function SetPrompt()
    if State.cwd == State.home then
        State.prompt = '$ '
    else
        State.prompt = State.cwd .. ' $ '
    end
end
