love.filesystem.setRequirePath('?.lua;?/init.lua;engine/?.lua;engine/?/init.lua;lib/?.lua;lib/?/init.lua')

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

function love.conf(t)
    t.window.width = WINDOW_WIDTH
    t.window.height = WINDOW_HEIGHT
    t.window.title = 'PETECATAQUE'
    t.window.icon = 'icon.png'
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
        excludeFileList = {'.DS_Store', 'TODO', 'tools/', 'DEBUG.lua'},     -- File patterns to exclude. (string list)
        releaseDirectory = 'release',   -- Where to store the project releases (string)
    }
end
