Spine = require('spine')
FITS = require('fits')

class FitImage extends Spine.Model
  @configure 'FitImage', 'file', 'context', 'image'

  #@file: binary fits file
  #@context: context of a html5 canvas object
  constructor: (@file, @context) ->
    super
    fits = new FITS.File(@file)
    @image = fits.getDataUnit()
    @data = @image.getFrame()
  
  getImageData: ->
    imageData = @context.createImageData(@image.width,@image.height)
    for x in [0..(imageData.width-1)]
      for y in [0..(imageData.height-1)]
        @setImageDataPixel(imageData,x,y,@getRGBAPixel(x,y))
    return imageData
  
  #Stores pixel at the correct location in the imageData object
  setImageDataPixel: (imageData,x,y,rgba) ->
    index = (x+y*imageData.width)*4
    imageData.data[index+0] = rgba[0]
    imageData.data[index+1] = rgba[1]
    imageData.data[index+2] = rgba[2]
    imageData.data[index+3] = rgba[3]
  
  #Note: (0,0) is top corner on html5 canvas
  #This new getPixel method takes this into account
  getPixel: (x,y) ->
    return @data[((@image.height-1)-y)*@image.width+x]

  #Return a RGBA pixel representation
  getRGBAPixel: (x,y) ->
    [min, max] = @image.getExtremes()
    range = max - min
    rawValue = @getPixel(x,y)
    normalVal = Math.floor(255*((rawValue - min)/range))
    return [normalVal,normalVal,normalVal,255]

  #Scale using nearest neighbor algorithm
  scaleImageData: (imageData,scale) ->
    scaledData = @context.createImageData(imageData.width*scale,imageData.height*scale)
    for x in [0..(scaledData.width-1)]
      for y in [0..(scaledData.height-1)]
        index = (x+y*scaledData.width)*4
        orig_x = Math.floor(x/scale)
        orig_y = Math.floor(y/scale)
        orig_index = (orig_x+orig_y*imageData.width)*4
        scaledData.data[index+0] = imageData.data[orig_index+0]
        scaledData.data[index+1] = imageData.data[orig_index+1]
        scaledData.data[index+2] = imageData.data[orig_index+2]
        scaledData.data[index+3] = imageData.data[orig_index+3]

    return scaledData


module.exports = FitImage
