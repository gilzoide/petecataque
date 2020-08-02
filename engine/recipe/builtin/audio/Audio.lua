local Audio = Recipe.wrapper.new('Audio', {
    getters = {
        'getActiveEffects', 'getActiveSourceCount', 'getDistanceModel',
        'getDopplerScale', 'getMaxSceneEffects', 'getMaxSourceEffects',
        'getOrientation', 'getPosition', 'getRecordingDevices',
        'getVelocity', 'getVolume', 'isEffectsSupported', 
    },
    setters = {
        'setDistanceModel', 'setDopplerScale', 'setMixWithSystem',
        'setOrientation', 'setPosition', 'setVelocity', 'setVolume',
    },
    methods = {
        'getEffect', 'pause', 'play', 'setEffect', 'stop',
    },
})

function Audio:create_wrapped()
    return love.audio
end

return Audio