local empty = require 'empty'

local DEBUG = {
    x = 0, y = 0,
    sx = 1, sy = 1,
    errors = {},
}

DEBUG.hotreload = require 'DEBUG.hotreload'

DEBUG.enabled = true

function DEBUG.LOG(...)
    io.stderr:write(...)
    io.stderr:write('\n')
end

function DEBUG.LOGF(fmt, ...)
    local msg = string.format(fmt or "", ...)
    DEBUG.LOG(msg)
end

function DEBUG.STARTTIMER(name)
    DEBUG[name] = love.timer.getTime()
end

function DEBUG.REPORTTIMER(name)
    DEBUG.LOG('DEBUG.REPORTTIMER', name, love.timer.getTime() - DEBUG[name])
end

function DEBUG.FILE_LINE(obj)
    local s = {}
    s[1] = obj.__file
    s[2] = obj.__line
    if #s > 0 then
        s[#s + 1] = ""
        return table.concat(s, ':')
    else
        return ""
    end
end

local function stringify_call(c)
    local recipe, name = unpack(c)
    local where = DEBUG.FILE_LINE(recipe)
    return string.format("\t%s '%s.%s'", where, recipe[1], name)
end

local function stringified_traceback()
    local msg = { 'recipe traceback:' }
    for i = #DEBUG, 1, -1 do
        table.insert(msg, stringify_call(DEBUG[i]))
    end
    return table.concat(msg, '\n')
end

function DEBUG.PUSH_CALL(recipe, name)
    table.insert(DEBUG, { recipe, name })
end

function DEBUG.POP_CALL(recipe, name)
    local t = table.remove(DEBUG)
    assertf(t and t[1] == recipe and t[2] == name, "FIXME @ %s", stringify_call(t))
end

function DEBUG.DUMP_TRACE(msg)
    DEBUG.LOG(msg)
    DEBUG.LOG(stringified_traceback())
end

function DEBUG.LOAD(arg)
    DEBUG.hotreload.load()
    DEBUG.font = love.graphics.newFont(14)
    DEBUG.scene = Scene.new()
    --DEBUG.error_scene = R('DEBUG_error_scene')()
    --DEBUG.error_message_recipe = R('DEBUG_error_message')
    --DEBUG.scene:add(DEBUG.error_scene)
    DEBUG.toolbar = R('DEBUG_Toolbar')()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT + DEBUG.toolbar.height)
    DEBUG.scene:add(DEBUG.toolbar)
    if arg[1] == '--debug' then
        require 'debugger'()
        table.remove(arg, 1)
    end
end

function DEBUG.UPDATE(dt)
    DEBUG.hotreload.update(dt)
    Director.update(dt, DEBUG.scene)
end

function DEBUG.PREDRAW()
    love.graphics.scale(DEBUG.sx, DEBUG.sy)
    love.graphics.translate(DEBUG.x, DEBUG.y)
end

function DEBUG.DRAW()
    love.graphics.origin()
    Director.draw(DEBUG.scene)
end

function DEBUG.WARN(fmt, ...)
    local msg = string.format(fmt, ...)
    local recipe_traceback = stringified_traceback()
    local lua_traceback = debug.traceback()
    DEBUG.LOG(msg)
    DEBUG.LOG(recipe_traceback)
    DEBUG.LOG(lua_traceback)
    --local error_message = DEBUG.error_message_recipe { message = msg, recipe_traceback = recipe_traceback, lua_traceback = lua_traceback }
    --DEBUG.error_scene:add_child(error_message)
    --table.insert(DEBUG.errors, { msg, recipe_traceback, lua_traceback })
end
function DEBUG.WARNIF(cond, ...)
    if cond then
        DEBUG.WARN(...)
    end
end

function love.errorhandler(msg)
    DEBUG.DUMP_TRACE(msg)
    DEBUG.LOG(debug.traceback())
end

return DEBUG
