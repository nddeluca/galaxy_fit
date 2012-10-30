require('lib/setup')
FitImage = require('models/FitImage')

FITS = require('fits')

Spine = require('spine')

class App extends Spine.Controller
  constructor: ->
    super

    xhr = new XMLHttpRequest()
    xhr.open('GET', 'images/ell1_cutout.fits')
    xhr.responseType = 'arraybuffer'
		
    xhr.send()
    @render()

    xhr.onload = (e) ->
      fits = new FITS.File(xhr.response)

      container = document.getElementById('canvasContainer')
      canvas = document.createElement('canvas')
      container.appendChild(canvas)
      ctx=canvas.getContext('2d')

      img = new FitImage(fits,ctx)
      scale = 8
      canvas.width = img.image.width*scale
      canvas.height = img.image.height*scale
      imageData = img.getImageData()
      scaledData = img.scaleImageData(imageData,scale)
      console.log scaledData
      ctx.putImageData(scaledData,0,0)

  render: =>
    @html require('views/main')

module.exports = App
    
