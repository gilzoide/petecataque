local ninja = require 'BUILD.lib.ninja_syntax'

local ignore = shallowcopy(ignore_patterns)
setmetatable(ignore, wildcard_pattern.aggregate)
ignore:extend("engine/DEBUG", "engine/BUILD", "*.md")

local iswindows = love.system.getOS() == 'Windows'

function generate(output_file)
    local writer = ninja.Writer.new(output_file or 'build.ninja')
    if iswindows then
        writer:include('engine/BUILD/windows.ninja')
    else
        writer:include('engine/BUILD/unix.ninja')
    end
    writer:include('engine/BUILD/common.ninja'):newline()

    writer:variable('builddir', 'build'):newline()
    local files = {}
    local source = love.filesystem.getSource()
    for filename, path in iter_file_tree('', ignore) do
        if love.filesystem.getRealDirectory(path):startswith(source) then
            table.insert(files, path)
            writer:build('build/' .. path, 'copy', path)
        end
    end

    local identity = love.filesystem.getIdentity() or 'game'
    local love_file = string.format('build/%s.love', identity)
    writer:build(love_file, 'zip', files)
    writer:default(love_file):newline()

    local love_version = '11.3'  -- TODO: use love.getVersion
    local win32_love = string.format('love-%s-win32', love_version)
    local win32_exe = string.format('build/%s_win32.zip', identity)
    writer:build(win32_exe, 'win32_exe', { 'build/exe/' .. win32_love, love_file }, 'engine/BUILD/patch_windows_exe.sh')
    writer:build('win32', 'phony', win32_exe):newline()

    writer:build('all', 'phony', { 'win32' })
    writer:close()
end

return generate
