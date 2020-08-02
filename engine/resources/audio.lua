local audio = {}

function audio.load_stream(filename)
    return love.audio.newSource(filename, 'stream')
end

function audio.load_static(filename)
    return love.audio.newSource(filename, 'static')
end

return audio