local Texture = Recipe.wrapper.new('Texture', 'texture', {
    'getDPIScale', 'getDepth', 'getDepthSampleMode', 'getDimensions',
    'getFilter', 'getFormat', 'getHeight', 'getLayerCount',
    'getMipmapCount', 'getMipmapFilter', 'getPixelDimensions',
    'getPixelHeight', 'getPixelWidth', 'getTextureType', 'getWidth',
    'getWrap', 'isReadable',
}, {
    'setDepthSampleMode', 'setFilter', 'setMipmapFilter', 'setWrap'
}, nil)

function Texture:create_wrapped()
    error("Cannot create Texture directly, use Image or Canvas instead")
end

return Texture