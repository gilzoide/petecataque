local empty = require 'empty'

local DEBUG = {
    errors = {},
}

DEBUG.hotreload = require 'DEBUG.hotreload'

DEBUG.enabled = true

function DEBUG.STARTTIMER(name)
    DEBUG[name] = love.timer.getTime()
end

function DEBUG.REPORTTIMER(name)
    print('DEBUG.REPORTTIMER', name, love.timer.getTime() - DEBUG[name])
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
    print(msg)
    print(stringified_traceback())
end

function DEBUG.LOAD(arg)
    DEBUG.hotreload.load()
    DEBUG.error_scene = Recipe.load_nested('engine/DEBUG/error_scene.nested')()
    DEBUG.error_message_recipe = Recipe.load_nested('engine/DEBUG/error_message.nested')
    DEBUG.scene = Scene.new()
    DEBUG.scene:add(DEBUG.error_scene)
    if arg[2] == '--debug' then
        require 'debugger'()
    end
end

function DEBUG.UPDATE(dt)
    DEBUG.hotreload.update(dt)
end

function DEBUG.DRAW()
    Director.draw(DEBUG.scene)
end

function DEBUG.WARN(fmt, ...)
    local msg = string.format(fmt, ...)
    local recipe_traceback = stringified_traceback()
    local lua_traceback = debug.traceback()
    print(msg)
    print(recipe_traceback)
    print(debug.traceback())
    table.insert(DEBUG.errors, { msg, recipe_traceback, lua_traceback })
end
function DEBUG.WARNIF(cond, ...)
    if cond then
        DEBUG.WARN(...)
    end
end

function love.errorhandler(msg)
    DEBUG.DUMP_TRACE(msg)
    print(debug.traceback())
end

return DEBUG
