Spine = require('spine')

class SersicProfile extends Spine.Model
  @configure 'SersicProfile','context','centerx','centery','intensity','coeff','effRad','width','height'

  constructor: (@centerx,@centery,@context,@width,@height) ->
    super
    @intensity = 55
    @coeff = 7.669
    @effRad = 35
    @n = 1
    @buildImageData()

  buildImageData: ->
    @data = new Float32Array(@width*@height)
    for x in [0..(@width-1)]
      for y in [0..(@height-1)]
        index = x+y*@width
        @data[index] = @getFunctionValue(x,y)

  getImageData: ->
    imageData = @context.createImageData(@width,@height)
    for x in [0..(@width-1)]
      for y in [0..(@height-1)]
        @setImageDataPixel(imageData,x,y,@getRGBAPixel(x,y))
    return imageData

  setImageDataPixel: (imageData,x,y,rgba) ->
    index = (x+y*@width)*4
    imageData.data[index+0] = rgba[0]
    imageData.data[index+1] = rgba[1]
    imageData.data[index+2] = rgba[2]
    imageData.data[index+3] = rgba[3]

  getRGBAPixel: (x,y) ->
    [min, max] = @getExtremes()
    range = max - min
    rawValue = @data[x+y*@width]
    normalVal = Math.floor(255*((rawValue - min)/range))
    return [normalVal,normalVal,normalVal,255]

  getFunctionValue: (x,y) ->
    x_cent = x - @centerx
    y_cent = y - @centery
    r = Math.sqrt(x_cent*x_cent + y_cent*y_cent)

    exponent = @coeff*Math.pow(r/@effRad,1/@n) - 1
    return @intensity*Math.exp(-exponent)

  scaleImageData: (funcData,scale) =>
    scaledData = @context.createImageData(funcData.width*scale,funcData.height*scale)
    for x in [0..(scaledData.width-1)]
      for y in [0..(scaledData.height-1)]
        index = (x+y*scaledData.width)*4
        orig_x = Math.floor(x/scale)
        orig_y = Math.floor(y/scale)
        orig_index = (orig_x+orig_y*funcData.width)*4
        scaledData.data[index+0] = funcData.data[orig_index+0]
        scaledData.data[index+1] = funcData.data[orig_index+1]
        scaledData.data[index+2] = funcData.data[orig_index+2]
        scaledData.data[index+3] = funcData.data[orig_index+3]

    return scaledData

  getExtremes: ->
    return [Math.min.apply(Math, @data), Math.max.apply(Math, @data)]

module.exports = SersicProfile
