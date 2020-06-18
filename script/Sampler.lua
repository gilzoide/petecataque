local oscillators = denver.oscillators
local BYTES_PER_SAMPLE = 2
PIXELS_PER_SAMPLE = 2
stored_samples_size = WINDOW_WIDTH / PIXELS_PER_SAMPLE
start_playing = true
freq = 440
gain = 1.0
y = WINDOW_HEIGHT * 0.5

function init()
    refresh_oscillator()
    sound_data = love.sound.newSoundData(denver.rate, denver.rate, denver.bits, denver.channel)
    source = love.audio.newQueueableSource(denver.rate, denver.bits, denver.channel)
    stored_samples = {}
    queue(0.5)
    if start_playing then source:play() end
end

function refresh_oscillator(osc_type)
    local constructor = oscillators[osc_type] or oscillators.sinus
    osc = constructor(freq)
end

function queue(dt)
    local buffer_size = math.ceil(dt * denver.rate)
    local sample
    for i = 0, buffer_size do
        sample = osc()
        stored_samples[i * 2 + 1] = i * PIXELS_PER_SAMPLE
        stored_samples[i * 2 + 2] = y + sample * 10
        sound_data:setSample(i, sample * 0.2)
    end
    source:queue(sound_data, buffer_size * BYTES_PER_SAMPLE)
end

function update(dt)
    queue(dt)
end

function draw()
    love.graphics.line(stored_samples)
end

when = {}
local osc_types = {
    'sinus',
    'sawtooth',
    'square',
    'triangle',
    'whitenoise',
    'pinknoise',
    'brownnoise',
}
for i = 1, #osc_types do
    when[#when + 1] = {{ 'Input.keypressed.' .. tostring(i) }, function()
        refresh_oscillator(osc_types[i])
    end}
end
