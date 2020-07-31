local Fixture = Recipe.wrapper.new('Fixture', {
    wrapped_index = 'fixture',
    getters = {
        'getBody', 'getCategory', 'getDensity', 'getFilterData',
        'getFriction', 'getGroupIndex', 'getMask', 'getMassData',
        'getRestitution', 'getShape', -- 'getUserData',
        'isDestroyed', 'isSensor',
    },
    setters = {
        'setCategory', 'setDensity', 'setFilterData', 'setFriction',
        'setGroupIndex', 'setMask', 'setRestitution', 'setSensor',
        -- 'setUserData',
    },
    methods = {
        'getBoundingBox', 'rayCast', 'testPoint',
    },
})

function Fixture:create_wrapped()
    local body, shape = self.body, self.shape
    if not body then
        body = self:first_parent_of('Body')
        self.body = body
        DEBUG.WARNIF(not body, "Unable to create fixture without a body")
    end
    if not shape then
        shape = self:first_parent_of('Shape')
        self.shape = shape
        DEBUG.WARNIF(not shape, "Unable to create fixture without a shape")
    end

    if body and shape then
        local fixture = love.physics.newFixture(body.body, shape.shape)
        fixture:setUserData(self)
        return fixture
    else
        self.paused = true
    end
end

return Fixture
