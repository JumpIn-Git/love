Builtins = {}

Builtins['cd'] = function(args)
    local parser = argparse('cd', 'Change directory.')
    parser:argument('dir'):default(State.home)
    local ok, res = CallParseNoExit(parser, args)
    if not ok then return 1 end
    res.dir = ExpandTilde(res.dir)

    local old_pwd = posix.getenv('PWD') or State.cwd
    local success, err_msg = posix.chdir(res.dir)
    if not success then
        io.stderr:write('cd: ' .. (err_msg or 'unknown error') .. '\n')
        return 1
    end
    State.cwd = posix.getcwd()
    posix.setenv('OLDPWD', old_pwd, true)
    posix.setenv('PWD', State.cwd, true)
    return 0
end

Builtins['exit'] = function(args)
    local parser = argparse('exit', 'exit ' .. Name .. '.')
    parser:argument('code'):default('0'):convert(tonumber)
    local ok, res = CallParseNoExit(parser, args)
    if not ok then
        return 1
    end
    io.flush()
    posix._exit(res.code)
end

Builtins['status'] = function(args)
    print(State.status)
    return 0
end

Builtins['export'] = function(args)
    local parser = argparse('export', 'Export a value.')
    parser:argument('name=value'):args('+'):convert(function(a) ---@param a string
        local pos = a:find('=', nil, true)
        if not pos then return nil, 'invalid format; use name=value' end
        return { a:sub(1, pos - 1), a:sub(pos + 1) }
    end)
    local ok, res = CallParseNoExit(parser, args)
    if not ok then return 1 end
    for _, t in ipairs(res['name=value']) do
        local _, err = posix.setenv(t[1], t[2])
        if err then
            io.stderr:write('export: ' .. err .. '\n')
            return 1
        end
    end
    return 0
end
