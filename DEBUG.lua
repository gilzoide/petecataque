local DEBUG = {}

DEBUG.enabled = true

function DEBUG.starttimer(name)
    DEBUG[name] = love.timer.getTime()
end

function DEBUG.reporttimer(name)
    print('DEBUG.reporttimer', name, love.timer.getTime() - DEBUG[name])
end

return DEBUG