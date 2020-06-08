require 'globals'
local entity = require 'entity'
local scene = require 'scene'
local systems = require 'systems'

local world
local current_scene

function love.load()
    entity.loadall()
    world = tiny.world(unpack(systems.loadall()))
    current_scene = scene.instantiate('Main')
    world:add(unpack(current_scene))
    world:refresh()
    print(world:getEntityCount(), world:getSystemCount())
end

local outside_dt
function love.update(dt)
    outside_dt = dt
end

function love.draw()
    world:update(outside_dt)
end