local systems = {}

function systems.loadall()
    local result = {}
    local folder = 'systems'
    for i, filename in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local basename = filename:match('(.+).lua$')
        if basename then
            local system = assert(loadfile(folder .. '/' .. filename))()
            result[basename] = system
            result[#result + 1] = system
        end
    end
    return result
end

return systems