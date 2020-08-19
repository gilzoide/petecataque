if love.filesystem then
    love.filesystem.setRequirePath('?.lua;?/init.lua;engine/?.lua;engine/?/init.lua;lib/?.lua;lib/?/init.lua')
end

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

do
    local success, m = pcall(require, 'DEBUG')  -- DEBUG is excluded on release
    DEBUG = success and m or setmetatable({ enabled = false }, require 'empty')
    assert(DEBUG.enabled ~= nil, "FIXME")
end

function love.conf(t)
    t.window.width = WINDOW_WIDTH
    t.window.height = WINDOW_HEIGHT + (DEBUG.enabled and DEBUG.toolbar_height or 0)
    t.identity = 'petecataque'
    t.window.title = 'PETECATAQUE'
    t.window.icon = 'assets/icon.png'
    t.window.highdpi = true
    t.window.msaa = 16
    
    t.releases = {
        title = 'PETECATAQUE',              -- The project title (string)
        package = 'petecataque',            -- The project command and package name (string)
        loveVersion = '11.3',        -- The project LÖVE version
        version = '0.2',            -- The project version
        author = 'gilzoide',             -- Your name (string)
        email = 'gilzoide@gmail.com',              -- Your email (string)
        description = nil,        -- The project description (string)
        homepage = 'https://github.com/gilzoide/love-nested-test-game',           -- The project homepage (string)
        identifier = 'com.gilzoide.petecataque',         -- The project Uniform Type Identifier (string)
        excludeFileList = {'.DS_Store', 'TODO', 'tools/', 'engine/DEBUG/', 'engine/*.md'},     -- File patterns to exclude. (string list)
        releaseDirectory = 'release',   -- Where to store the project releases (string)
    }
end
