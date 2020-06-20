WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

function love.conf(t)
    t.window.width = WINDOW_WIDTH
    t.window.height = WINDOW_HEIGHT
    t.window.title = 'PTKATK'
    t.window.icon = 'icon.png'
    t.window.highdpi = true
    
    t.releases = {
        title = 'PTKATK',              -- The project title (string)
        package = 'ptkatk',            -- The project command and package name (string)
        loveVersion = '11.3',        -- The project LÖVE version
        version = '0.1',            -- The project version
        author = 'gilzoide',             -- Your name (string)
        email = 'gilzoide@gmail.com',              -- Your email (string)
        description = nil,        -- The project description (string)
        homepage = 'https://github.com/gilzoide/love-nested-test-game',           -- The project homepage (string)
        identifier = 'com.gilzoide.ptkatk',         -- The project Uniform Type Identifier (string)
        excludeFileList = {'.DS_Store', 'TODO', 'tools/', 'DEBUG.lua'},     -- File patterns to exclude. (string list)
        releaseDirectory = 'release',   -- Where to store the project releases (string)
    }
end