local usage = arg[0] .. ' <input> <output>'
assert(arg[1], 'Missing <input>\n' .. usage)
assert(arg[2], 'Missing <output>\n' .. usage)

io.input(arg[1])
io.output(arg[2])

local content = io.read('*a')
content = content:gsub('%s*DEBUG%.[^%s(]+%b()', '')
io.write(content)
