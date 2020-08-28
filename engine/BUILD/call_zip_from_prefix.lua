local usage = arg[0] .. ' <prefix> <output> <inputs...>'
assert(arg[1], 'Missing <prefix>\n' .. usage)
assert(arg[2], 'Missing <output>\n' .. usage)
assert(arg[3], 'Missing <inputs...>\n' .. usage)

local prefix = arg[1]
local function strip_prefix(s)
    return string.format("%q", s:sub(#prefix + 1))
end

local output = strip_prefix(arg[2])
local input = {}
for i = 3, #arg do table.insert(input, strip_prefix(arg[i])) end

local cmd = string.format("cd %q && zip -9 %s %s", prefix, output, table.concat(input, ' '))
assert(io.popen(cmd)):read('*a')
