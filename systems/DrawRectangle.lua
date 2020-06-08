local DrawRectangle = tiny.processingSystem()
DrawRectangle.filter = tiny.requireAll('color', 'rectangle')

function DrawRectangle:process(entity, dt)
    love.graphics.setColor(entity.color)
    love.graphics.rectangle('fill', unpack(entity.rectangle))
end

return DrawRectangle
