local When = Recipe.new('When')

function When:__init_recipe(recipe)
    local condition_actions = {}
    for k, v in nested.kpairs(recipe) do
        assertf(type(k) == 'string', "Unexpected non-string non-number key in When: %q", type(k))
        if not k:startswith("__") then
            assertf(Expression.is_expression(v), "When action for %q should be callable: %q", k, nested.encode(v))
            condition = assert(nested.decode(k))
            table.insert(condition_actions, { condition, v })
        end
    end
    recipe.__when = condition_actions
end

function When:update(dt)
    local condition_actions = self.__when
    local obj = self.parent
    for i = 1, #condition_actions do
        local t = condition_actions[i]
        local condition, action = t[1], t[2]
        if nested_match(obj, condition) then
            DEBUG.PUSH_CALL(action, nested.encode(action))
            action(obj)
            DEBUG.POP_CALL(action, nested.encode(action))
        end
    end
end

return When
