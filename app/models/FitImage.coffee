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
    @data = @getData()
    [@min,@max] = @getExtremes()
    @range = @max - @min

  getData: ->
    return @image.getFrame()

  getPixel: (x,y) ->
    return @image.getPixel(x,y)

  getRGBValue: (x,y) ->
    r = Math.round(255*(@image.getPixel(x,y) - @min) / @range)
    return "rgb(#{r},#{r},#{r})"

  getExtremes: ->
    return [Math.min.apply(Math, @data), Math.max.apply(Math, @data)]

module.exports = FitImage
