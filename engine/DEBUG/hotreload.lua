local hotreload = {}

local function fswatch_cmd(watch_paths)
    -- https://github.com/emcrisostomo/fswatch
    return 'fswatch --event Updated ' .. table.concat(watch_paths, ' ')
end

function hotreload.load()
    hotreload.channel = love.thread.getChannel('DEBUG.hotreload')
    hotreload.source = love.filesystem.getSource()
    love.thread.newThread([[
    local channel, fswatch_cmd = ...
    local fswatch = io.popen(fswatch_cmd)
    if fswatch:read(0) then
        for line in fswatch:lines() do
            channel:push(line)
        end
    else
        print(string.format('DEBUG.HOTRELOAD failed running %q and is disabled', fswatch_cmd))
    end
    ]]):start(hotreload.channel, fswatch_cmd(R.path))
end

function hotreload.update(dt)
    while hotreload.channel:getCount() > 0 do
        local line = hotreload.channel:pop()
        if line:startswith(hotreload.source) then
            line = line:sub(#hotreload.source + 2)
        end
        print('DEBUG.HOTRELOAD', line)
        R:unload(line)
    end
end

return hotreload