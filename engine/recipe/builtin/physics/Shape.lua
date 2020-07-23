local Shape = Recipe.wrapper.new('Shape', {
    wrapped_index = 'shape',
    getters = {
        'getChildCount', 'getRadius', 'getType',
    },
    methods = {
        'computeAABB', 'computeMass', 'rayCast', 'testPoint',
    }
})

function Shape:create_wrapped()
    error("Cannot create Shape directly, use ChainShape, CircleShape, EdgeShape, PolygonShape or RectangleShape instead")
end

return Shape