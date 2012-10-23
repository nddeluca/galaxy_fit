require('lib/setup')
FITS = require('fits')

Spine = require('spine')

class App extends Spine.Controller
  constructor: ->
    super

    xhr = new XMLHttpRequest()
    xhr.open('GET', 'images/simulated_ellipse.fits')
    xhr.responseType = 'arraybuffer'
		
    xhr.send()
    @render()

    xhr.onload = (e) ->
      c = document.getElementById('mainCanvas')
      ctx=c.getContext("2d")

      fits = new FITS.File(xhr.response)
      console.log fits.getDataUnit()
      image = fits.getDataUnit()
      data = image.getFrame()

      FindMax = (array) ->
        return Math.max.apply(Math,array)
      FindMin = (array) ->
        return Math.min.apply(Math,array)

      max = FindMax(data)
      min = FindMin(data)
      range = max - min

      for x in [0..199]
        for y in [0..199]
          pixel = 255 * (image.getPixel(x,y) - min) / range
          r = Math.round(pixel)
          ctx.fillStyle = "rgb(#{r},#{r},#{r})"
          ctx.fillRect(x,y,1,1)

  render: =>
    @html require('views/main')

module.exports = App
    
