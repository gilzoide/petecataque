local AssetMap = {}
AssetMap.__index = AssetMap

function AssetMap.split_extension(path)
    local basename, ext = path:match("^([^.]*)(.*)")
    return basename, ext
end

local function scan_dir(self, dir, info)
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local path = dir .. '/' .. item
        love.filesystem.getInfo(path, info)
        if info.type == 'directory' then
            scan_dir(self, path, info)
        elseif info.type == 'file' then
            self[path] = path
            if self[item] == nil then
                self[item] = path
            elseif self[item] ~= false then
                log.warnassert(false, "Resource filename at path %q matches %q. Disabling loading filename %q", path, self[item], item)
                self[item] = false
            end

            local basename, ext = AssetMap.split_extension(item)
            if self[basename] == nil then
                self[basename] = path
            elseif self[basename] ~= false then
                log.warnassert(false, "Resource basename at path %q matches %q. Disabling loading basename %q", path, self[basename], basename)
                self[basename] = false
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
    return assertf(self[file], "Couldn't find file %q", file)
end

return AssetMap