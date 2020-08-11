local AssetMap = {}
AssetMap.__pairs = default_object_pairs

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

local function scan_dir(self, dir)
    local by_filename, by_basename = self.__filename, self.__basename
    for item, path in iter_file_tree(dir, ignore_patterns) do
        local t = setmetatable({ __path = path }, asset_map_mt)
        self[path] = t

        if by_filename[item] == nil then
            by_filename[item] = t
        elseif by_filename[item] ~= false then
            DEBUG.WARN("Resource filename at path %q matches %q. Disabling loading filename %q", path, by_filename[item].path, item)
            by_filename[item] = false
        end

        local basename, ext = AssetMap.split_extension(item)
        if by_basename[basename] == nil then
            by_basename[basename] = t
        elseif by_basename[basename] ~= false then
            DEBUG.WARN("Resource basename at path %q matches %q. Disabling loading basename %q", path, by_basename[basename].path, basename)
            by_basename[basename] = false
        end
    end
end

function AssetMap.new(search_paths)
    local asset_map = { __basename = {}, __filename = {} }
    for i, dir in ipairs(search_paths) do
        scan_dir(asset_map, dir)
    end
    return setmetatable(asset_map, AssetMap)
end

function AssetMap:full_path(file)
    return get(self, file, '__path')
end

local methods = {
    full_path = AssetMap.full_path,
}
function AssetMap:__index(index)
    return index_first_of(index, methods, rawget(self, '__filename'), rawget(self, '__basename'))
end

return AssetMap
