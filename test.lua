local unistd = require("posix.unistd")
local syswait = require("posix.sys.wait")

-- 1. Create the pipe
-- rd is the read end (stdin for command 2)
-- wr is the write end (stdout for command 1)
local rd, wr = unistd.pipe()
if not rd then
    error("Failed to create pipe")
end

-- 2. Fork the first process (Writer: 'ls -l')
local pid1 = unistd.fork()
if pid1 == 0 then
    -- Inside Child 1
    unistd.close(rd)                      -- Child 1 doesn't need to read from the pipe
    unistd.dup2(wr, unistd.STDOUT_FILENO) -- Redirect stdout to the pipe's write end
    unistd.close(wr)                      -- Clean up the duplicated descriptor

    unistd.execp("ls", { "-l" })
    error("execp failed") -- execp only returns if it fails
elseif pid1 < 0 then
    error("First fork failed")
end

-- 3. Fork the second process (Reader: 'grep lua')
local pid2 = unistd.fork()
if pid2 == 0 then
    -- Inside Child 2
    unistd.close(wr)                     -- Child 2 doesn't need to write to the pipe
    unistd.dup2(rd, unistd.STDIN_FILENO) -- Redirect stdin to the pipe's read end
    unistd.close(rd)                     -- Clean up the duplicated descriptor

    unistd.execp("grep", { "lua" })
    error("execp failed") -- execp only returns if it fails
elseif pid2 < 0 then
    error("Second fork failed")
end

-- 4. Main Parent Process Cleanup
-- CRITICAL: The parent MUST close its copies of the pipe descriptors.
-- If 'wr' stays open in the parent, 'grep' will hang forever waiting for EOF.
unistd.close(rd)
unistd.close(wr)

-- 5. Wait for both children to finish
syswait.wait(pid1)
syswait.wait(pid2)
