local Fixture = Recipe.wrapper.new('Fixture', {
    'getBody', 'getCategory', 'getDensity', 'getFilterData',
    'getFriction', 'getGroupIndex', 'getMask', 'getMassData',
    'getRestitution', 'getShape', -- 'getUserData',
    'isDestroyed', 'isSensor',
}, {
    'setCategory', 'setDensity', 'setFilterData', 'setFriction',
    'setGroupIndex', 'setMask', 'setRestitution', 'setSensor',
    -- 'setUserData',
}, {
    'getBoundingBox', 'rayCast', 'testPoint',
})

function Fixture:create_wrapped()
    local body, shape = self.body, self.shape
    if not body then
        body = select(2, self:first_parent_with('body'))
        self.body = body
        log.warnassert(body, "Unable to create fixture without a body")
    end
    if not shape then
        shape = select(2, self:first_parent_with('shape'))
        self.shape = shape
        log.warnassert(shape, "Unable to create fixture without a shape")
    end

    if body and shape then
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData(self)
        return fixture
    else
        self.disabled = true
    end
end

Fixture['$fixture'] = Recipe.wrapper.get_wrapped

return Fixture