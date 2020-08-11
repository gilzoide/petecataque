local ninja = require 'BUILD.lib.ninja_syntax'

local ignore = shallowcopy(ignore_patterns)
setmetatable(ignore, wildcard_pattern.aggregate)
ignore:extend("engine/DEBUG", "engine/BUILD", "*.md")

local iswindows = love.system.getOS() == 'Windows'

function generate(output_file)
    local writer = ninja.Writer.new(output_file or 'build.ninja')
    if iswindows then
        writer:include('engine/BUILD/windows.ninja'):newline()
    else
        writer:include('engine/BUILD/unix.ninja'):newline()
    end
    writer:variable('builddir', 'build'):newline()
    local files = {}
    local source = love.filesystem.getSource()
    for filename, path in iter_file_tree('', ignore) do
        if love.filesystem.getRealDirectory(path):startswith(source) then
            table.insert(files, path)
            writer:build('build/' .. path, 'copy', path)
        end
    end
    local zipname = love.filesystem.getIdentity() or 'game'
    writer:build(string.format('build/%s.love', zipname), 'zip', files)
    writer:close()
end

return generate
