local AssetMap = {}
AssetMap.__index = AssetMap

function AssetMap.split_extension(path)
    local basename, ext = path:match("^([^.]*)(.*)")
    return basename, ext
end

function AssetMap.get_basename(path)
    local basename = path:match("([^/.]*)[^/]-$")
    return basename
end

function AssetMap.get_filename(path)
    local filename = path:match("([^/]+)$")
    return filename
end


local asset_map_mt = {
    __pairs = default_object_pairs,
    __mode = "v",
}

local function scan_dir(self, dir, info)
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        if not item:startswith('.') then
            local path = dir .. '/' .. item
            love.filesystem.getInfo(path, info)
            if info.type == 'directory' then
                scan_dir(self, path, info)
            elseif info.type == 'file' then
                local t = setmetatable({ __path = path }, asset_map_mt)
                self[path] = t
                if self[item] == nil then
                    self[item] = t
                elseif self[item] ~= false then
                    DEBUG.WARN("Resource filename at path %q matches %q. Disabling loading filename %q", path, self[item].path, item)
                    self[item] = false
                end

                local basename, ext = AssetMap.split_extension(item)
                if self[basename] == nil then
                    self[basename] = t
                elseif self[basename] ~= false then
                    DEBUG.WARN("Resource basename at path %q matches %q. Disabling loading basename %q", path, self[basename].path, basename)
                    self[basename] = false
                end
            end
        end
    end
end

function AssetMap.new(search_paths)
    local asset_map, info = {}, {}
    for i, dir in ipairs(search_paths) do
        scan_dir(asset_map, dir, info)
    end
    return setmetatable(asset_map, AssetMap)
end

function AssetMap:full_path(file)
    return get(self, file, '__path')
end

return AssetMap
