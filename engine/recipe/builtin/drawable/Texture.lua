local Texture = Recipe.wrapper.new('Texture', {
    wrapped_index = 'texture',
    getters = {
        'getDPIScale', 'getDepth', 'getDepthSampleMode', 'getDimensions',
        'getFilter', 'getFormat', 'getHeight', 'getLayerCount',
        'getMipmapCount', 'getMipmapFilter', 'getPixelDimensions',
        'getPixelHeight', 'getPixelWidth', 'getTextureType', 'getWidth',
        'getWrap', 'isReadable',
    },
    setters = {
        'setDepthSampleMode', 'setFilter', 'setMipmapFilter', 'setWrap'
    },
})

function Texture:create_wrapped()
    error("Cannot create Texture directly, use Image or Canvas instead")
end

return Texture