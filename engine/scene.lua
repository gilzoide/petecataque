local table_pool = require 'table_pool'.raw
local table_stack = require 'table_stack'

local Scene = {}
Scene.__index = Scene

function Scene.new()
    return setmetatable({
        update = table_stack.new(),
        draw = table_stack.new(),
        dirty = true,
    }, Scene)
end

function Scene:add(obj)
    self[#self + 1] = obj
    self.dirty = true
end

function Scene:release()
    for i, obj in ipairs(self) do
        Object.release(obj)
    end
    self.dirty = true
end

-- Iteration and caching
local iterator_flags = { skip_root = true, postorder = true, table_only = true }
local function iterate_all_and_cache(scene, update_or_draw, skip_if_field, dt_on_update)
    scene.dirty = false
    local update = scene.update; update:clear()
    local draw = scene.draw; draw:clear()

    local update_previous = table_pool:acquire()
    local draw_previous = table_pool:acquire()
    local skipping_object = false

    local function process_obj_going_down(obj, method, stack, previous_cache, maybe_call)
        if method then
            previous_cache[obj] = stack:push(method, obj, stack.n + 1)
            if maybe_call and not skipping_object then
                if obj[skip_if_field] then
                    skipping_object = obj
                else
                    DEBUG.PUSH_CALL(obj, update_or_draw)
                    method(obj, dt_on_update)
                    DEBUG.POP_CALL(obj, update_or_draw)
                end
            end
        end
    end
    local function process_obj_going_up(obj, method, stack, previous_cache, maybe_call)
        if method then
            stack:push(method, obj, 0)
            if maybe_call and not skipping_object then
                DEBUG.PUSH_CALL(obj, update_or_draw)
                method(obj, dt_on_update)
                DEBUG.POP_CALL(obj, update_or_draw)
            end
        end
        if previous_cache[obj] then
            previous_cache[obj][3] = stack.n - previous_cache[obj][3]
            previous_cache[obj] = nil
        end
        if skipping_object == obj then
            skipping_object = false
        end
    end

    local is_update = update_or_draw == 'update'
    local is_draw = update_or_draw == 'draw'
    for kp, obj, parent, going_down in nested.iterate(scene, iterator_flags) do
        if going_down then
            process_obj_going_down(obj, obj.update, update, update_previous, is_update)
            process_obj_going_down(obj, obj.draw, draw, draw_previous, is_draw)
        else
            process_obj_going_up(obj, obj.late_update, update, update_previous, is_update)
            process_obj_going_up(obj, obj.late_draw, draw, draw_previous, is_draw)
        end
    end

    table_pool:release(update_previous)
    table_pool:release(draw_previous)
end

local function iterate_cached(scene, update_or_draw, skip_if_field, ...)
    local cache = scene[update_or_draw]
    local i = 1
    while i <= cache.n do
        local method, obj, children = unpack(cache[i])
        if not obj[skip_if_field] then
            method(obj, ...)
            i = i + 1
        else
            i = i + 1 + children
        end
    end
end

function Scene:call_update(...)
    local iterator_function = self.dirty and iterate_all_and_cache or iterate_cached
    iterator_function(self, 'update', 'paused', ...)
end

function Scene:call_draw(...)
    local iterator_function = self.dirty and iterate_all_and_cache or iterate_cached
    iterator_function(self, 'draw', 'hidden', ...)
end

function Scene:iterate()
    return nested.iterate(self, iterator_flags)
end

return Scene
