-- Code generated by nested2object
a = a or Rectangle({x = 50, y = 50, width = 50})
Rectangle({x = 200, y = 100, color = {0,1,0}})

function update(dt)
    a.transform:rotate(dt)
end

