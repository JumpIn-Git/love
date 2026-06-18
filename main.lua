io.stdout:setvbuf("no")
require 'builtins'
require 'lib'

Name = 'pojit'
State = {
    version = '0.0.0 (luaposix)',
    alias = {
        ls = { 'ls', { '--color=auto' }, }
    },
    status = nil
}

local parser = argparse(Name, 'A luaJIT shell using luaposix.')
parser:flag('-v --version')
local res = parser:parse()
if res.version then
    print(State.version)
    os.exit(0)
end

State.home = posix.getenv('HOME') or (posix.getpwuid(posix.getuid()) or {}).pw_dir or (function()
    io.stderr:write('shell-init: No HOME found, defaulting to root\n')
    return '/'
end)()
State.cwd = posix.getcwd() or (function()
    io.stderr:write('shell-init: error retrieving current directory, rescuing to HOME\n')
    local success = posix.chdir(State.home)
    if not success and State.home ~= '/' then
        posix.chdir('/')
        return '/'
    end
    return State.home
end)()

local function sigint_handler(signum)
    debug.sethook(
        function()      -- Hook will run before executing next line in correct context, resulting in a error stopping pcall
            debug.sethook() -- Immediately turn the hook off
            error(posix.SIGINT, 0)
        end, "", 1)
end
posix.signal(posix.SIGINT, sigint_handler)

while true do
    local ok, err = pcall(function()
        SetPrompt()
        io.write(State.prompt)
        io.flush()

        local input = io.read()
        if input == nil then -- Ctrl+D
            return posix.EOF
        end

        local args = {}
        for w in input:gmatch('%S+') do
            table.insert(args, w)
        end

        if #args > 0 then
            local program = table.remove(args, 1)
            Run(program, args) -- Executes builtins or external forks
        end
    end)

    if not ok then
        debug.sethook()

        if err == posix.SIGINT then
            State.status = 130 -- 128+SIGINT
            io.write('\n')
        else
            io.stderr:write('Shell Internal Error: ' .. tostring(err) .. '\n')
        end
    elseif err == posix.EOF then
        io.write('\n')
        break
    end
end
