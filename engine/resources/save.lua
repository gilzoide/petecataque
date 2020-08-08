local load_nested_data = require 'resources.data'
local AssetMap = require 'resources.asset_map'

local function write_save(t)
    assert(love.filesystem.write(t.__file, nested.encode(t)))
end

local function queue_write_save(t)
    if not t.__save_queued then
        t.__save_queued = true
        InvokeQueue:queue(write_save, t)
        InvokeQueue:queue(set, t, '__save_queued', false)
    end
end

local save_mt = {
    save_now = write_save,
    save = queue_write_save,
    __pairs = default_object_pairs,
}
save_mt.__index = save_mt

local function load_or_create_save(filename)
    if not filename:endswith('.save') then
        filename = filename .. '.save'
    end
    local saved_filename = AssetMap.get_filename(filename)
    local save_table = load_nested_data(saved_filename) or load_nested_data(filename) or {}
    save_table.__file = saved_filename
    return setmetatable(save_table, save_mt)
end

return load_or_create_save
