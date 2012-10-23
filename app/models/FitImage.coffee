Spine = require('spine')
FITS = require('fits')

class FitImage extends Spine.Model
  @configure 'FitImage', 'file', 'min', 'max', 'data', 'pixels', 'image', 'height', 'width'

  constructor: (@file) ->
    super
    @init()

  init: ->
    fits = new FITS.File(@file)
    @image = fits.getDataUnit()
    @data = @image.getFrame()
    [@min,@max] = @getExtremes()
    @range = @max - @min

  getPixel: (x,y) ->
    return @image.getPixel(x,y)
      
  #Map pixel to [0,1] interval
  getNormalizedPixel: (x,y) ->
    return (@image.getPixel(x,y) - @min) / @range

  getRGBValue: (x,y) ->
    r = Math.round(255*@getNormalizedPixel(x,y))
    return "rgb(#{r},#{r},#{r})"

  getExtremes: ->
    return [Math.min.apply(Math, @data), Math.max.apply(Math, @data)]

module.exports = FitImage
