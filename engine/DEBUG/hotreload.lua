local hotreload = {}

local function fswatch_cmd(watch_paths)
    -- https://github.com/emcrisostomo/fswatch
    return 'fswatch --recursive --event Updated ' .. table.concat(watch_paths, ' ')
end

function hotreload.load()
    hotreload.channel = love.thread.newChannel()
    hotreload.source = love.filesystem.getSource()
    love.thread.newThread([[
    local channel, fswatch_cmd = ...
    io.stderr:write(string.format("DEBUG.HOTRELOAD starting command: %q\n", fswatch_cmd))
    local fswatch = io.popen(fswatch_cmd)
    if fswatch:read(0) then
        for line in fswatch:lines() do
            channel:push(line)
        end
    else
        io.stderr:write(string.format('DEBUG.HOTRELOAD failed running %q and is disabled\n', fswatch_cmd))
    end
    ]]):start(hotreload.channel, fswatch_cmd(R.path))
end

local function iter_scene_reloading_objects(recipes_changed, previously_loaded, scene)
    local objects_iterator, skip = scene:iterate()
    while true do
        local kp, obj, parent = objects_iterator(skip)
        if not kp then break end
        local recipe_path = obj[1] and R.asset_map:full_path(obj[1])
        local previously_loaded = recipes_changed[recipe_path]
        if previously_loaded then
            parent[kp[#kp]] = hotreload.rebuild_object(obj, previously_loaded, R(recipe_path), parent ~= scene and parent or nil)
            skip = true
        else
            skip = false
        end
    end
end

function hotreload.update(dt)
    local recipes_changed
    while hotreload.channel:getCount() > 0 do
        local line = hotreload.channel:pop()
        if line:startswith(hotreload.source) then
            line = line:sub(#hotreload.source + 2)
        end
        DEBUG.LOGF('DEBUG.HOTRELOAD %q', line)
        local previously_loaded = R:get(line)
        R:unload(line)
        if Recipe.is_recipe(previously_loaded) then
            if not recipes_changed then recipes_changed = {} end
            recipes_changed[line] = previously_loaded
        end
    end

    if recipes_changed then
        iter_scene_reloading_objects(recipes_changed, previously_loaded, Scene)
        iter_scene_reloading_objects(recipes_changed, previously_loaded, DEBUG.scene)
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
    if root and type(obj.id) == 'string' then
        root['_' .. obj.id] = nil
    end
    local new_obj = new_recipe(nil, parent, root)
    hotreload.copy_state(obj, new_obj)
    Object.release(obj)
    return new_obj
end

function hotreload.copy_state(from_obj, to_obj)
    if from_obj and to_obj and from_obj[1] == to_obj[1] then
        for k, v in rawpairs(from_obj) do
            if type(k) == 'string' then
                if not k:startswith('_') then
                    to_obj[k] = v
                end
            end
        end

        local recipe_copy_state = from_obj.__recipe.__copy_state
        if iscallable(recipe_copy_state) then
            recipe_copy_state(from_obj, to_obj)
        elseif type(recipe_copy_state) == 'table' then
            for i, k in ipairs(recipe_copy_state) do
                to_obj[k] = from_obj[k]
            end
        end

        for i = 2, #to_obj do
            if not hotreload.copy_state(from_obj[i], to_obj[i]) then break end
        end
        return true
    else
        return false
    end
end

return hotreload
