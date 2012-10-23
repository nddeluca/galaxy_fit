require('lib/setup')
FitImage = require('models/FitImage')

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

      img = new FitImage(xhr.response)

      for x in [0..199]
        for y in [0..199]
          ctx.fillStyle = img.getRGBValue(x,y)
          ctx.fillRect(x,y,1,1)

  render: =>
    @html require('views/main')

module.exports = App
    
