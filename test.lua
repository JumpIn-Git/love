for i = 1, 5 do
    if i == 3 then
        debug.sethook(function()
            debug.sethook() -- Immediately turn the hook off
            error("hook", 0)
        end, "", 1)
    end
    print(i)
end
