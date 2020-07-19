local AssetMap = {}
AssetMap.__index = AssetMap

function AssetMap.split_extension(path)
    local basename, ext = path:match("^([^.]*)(.*)")
    return basename, ext
end

local function scan_dir(self, dir)
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local path = dir .. '/' .. item
        local info = love.filesystem.getInfo(path)
        if info.type == 'directory' then
            scan_dir(self, path)
        elseif info.type == 'file' then
            local basename, ext = AssetMap.split_extension(item)
            info.path = path
            info.ext = ext
            info.type = nil
            self[path] = info
            if self[item] == nil then
                self[item] = info
            elseif self[item] ~= false then
                log.warnassert(false, "Resource filename at path %q matches %q. Disabling loading filename %q", path, self[item].path, item)
                self[item] = false
            end

            if self[basename] == nil then
                self[basename] = info
            elseif self[basename] ~= false then
                log.warnassert(false, "Resource basename at path %q matches %q. Disabling loading basename %q", path, self[basename].path, basename)
                self[basename] = false
            end
        end
    end
end

function AssetMap.new(search_paths)
    local asset_map = {}
    for i, dir in ipairs(search_paths) do
        scan_dir(asset_map, dir)
    end
    return setmetatable(asset_map, AssetMap)
end

function AssetMap:full_path(file)
    return assertf(get(self, file, 'path'), "Couldn't find file %q", file)
end

return AssetMap