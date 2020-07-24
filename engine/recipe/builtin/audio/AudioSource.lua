local AudioSource = Recipe.wrapper.new('AudioSource', {
    wrapped_index = 'source',
    getters = {
        'getActiveEffects', 'getAirAbsorption', 'getAttenuationDistances',
        'getChannelCount', 'getCone', 'getDirection', 'getDuration',
        'getFilter', 'getFreeBufferCount', 'getPitch', 'getPosition',
        'getRolloff', 'getType', 'getVelocity', 'getVolume', 'getVolumeLimits',
        'isLooping', 'isPlaying', 'isRelative',
    },
    setters = {
        'setAirAbsorption', 'setAttenuationDistances', 'setCone', 'setDirection',
        'setFilter', 'setLooping', 'setPitch', 'setPosition', 'setRelative',
        'setRolloff', 'setVelocity', 'setVolume', 'setVolumeLimits',
    },
    methods = {
        'getEffect', 'setEffect', 'pause', 'play', 'queue', 'seek', 'stop', 'tell',
    },
})

function AudioSource:create_wrapped()
    local source = self.source
    if source then
        return source
    end
    
    local filename = self.filename
    local type = self.type
    if log.warnassert(filename and type, 'No filename or type for AudioSource: %s, %s', filename, type) then
        return R(filename, type)
    end
end

Object.add_setter(AudioSource, 'playing', function(self, playing)
    local source = self.source
    if source then
        if playing then
            source:play()
        else
            source:pause()
        end
    end
end)

return AudioSource