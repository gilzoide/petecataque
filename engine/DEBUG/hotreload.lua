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
    local recipes_changed
    while hotreload.channel:getCount() > 0 do
        local line = hotreload.channel:pop()
        if line:startswith(hotreload.source) then
            line = line:sub(#hotreload.source + 2)
        end
        print('DEBUG.HOTRELOAD', line)
        local previously_loaded = R:get(line)
        R:unload(line)
        if Recipe.is_recipe(previously_loaded) then
            if not recipes_changed then recipes_changed = {} end
            recipes_changed[line] = previously_loaded
        end
    end

    if recipes_changed then
        local objects_iterator, skip = Scene:iterate()
        while true do
            local kp, obj, parent = objects_iterator(skip)
            if not kp then break end
            local recipe_path = obj[1] and R.asset_map:full_path(obj[1])
            local previously_loaded = recipes_changed[recipe_path]
            if previously_loaded then
                parent[kp[#kp]] = hotreload.rebuild_object(obj, previously_loaded, R(recipe_path), parent)
                skip = true
            else
                skip = false
            end
        end
    end
end

function hotreload.rebuild_object(obj, old_recipe, new_recipe, parent)
    if obj.__recipe.__super == old_recipe then
        obj.__recipe.__super = new_recipe
        new_recipe = obj.__recipe
    elseif obj.__recipe ~= old_recipe then
        error("FIXME rebuilding wrong old_recipe")
    end

    local root = obj.__root
    Object.release(obj)
    return new_recipe(nil, parent, root)
end

return hotreload