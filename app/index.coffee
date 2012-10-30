require('lib/setup')
FitImage = require('models/FitImage')
SersicProfile = require('models/SersicProfile')

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

      imageContainer = document.getElementById('imageContainer')
      modelContainer = document.getElementById('modelContainer')
      residualContainer = document.getElementById('residualContainer')

      imageCanvas = document.createElement('canvas')
      modelCanvas = document.createElement('canvas')
      residualCanvas = document.createElement('canvas')

      imageContainer.appendChild(imageCanvas)
      modelContainer.appendChild(modelCanvas)
      residualContainer.appendChild(residualCanvas)

      imageContext = imageCanvas.getContext('2d')
      modelContext = modelCanvas.getContext('2d')
      residualContext = residualCanvas.getContext('2d')

      img = new FitImage(fits,imageContext)
      scale = 8
      scaledWidth = img.image.width*scale
      scaledHeight = img.image.height*scale
      imageCanvas.width = scaledWidth
      imageCanvas.height = scaledHeight
      imageData = img.getImageData()
      scaledData = img.scaleImageData(imageData,scale)
      imageContext.putImageData(scaledData,0,0)

      sersic = new SersicProfile(31.5,33.5,modelContext,img.image.width,img.image.height)
      modelCanvas.width = scaledWidth
      modelCanvas.height = scaledHeight
      funcData = sersic.getImageData()
      scaledFuncData = sersic.scaleImageData(funcData,scale)
      modelContext.putImageData(scaledFuncData,0,0)
      
      residualData = new Float32Array(scaledWidth*scaledHeight)
      residualCanvas.width = scaledWidth
      residualCanvas.height = scaledHeight

      for x in [0..(scaledWidth-1)]
        for y in [0..(scaledHeight-1)]
          index = (x+y*(scaledWidth))
          index2 = (x+y*(scaledWidth))*4
          residualData[index] = scaledData.data[index2] - scaledFuncData.data[index2]

      max = Math.max.apply(Math,residualData)
      min = Math.min.apply(Math,residualData)
      range = max - min
      
      finalResData = residualContext.createImageData(scaledWidth,scaledHeight)

      for x in [0..(scaledWidth-1)]
        for y in [0..(scaledHeight-1)]
          orig_index = (x+y*(scaledWidth))
          index = (x+y*(scaledWidth))*4
          finalResData.data[index+0] = Math.floor(255*((residualData[orig_index]-min)/range))
          finalResData.data[index+1] = Math.floor(255*((residualData[orig_index]-min)/range))
          finalResData.data[index+2] = Math.floor(255*((residualData[orig_index]-min)/range))
          finalResData.data[index+3] = 255
      residualContext.putImageData(finalResData,0,0)

  render: =>
    @html require('views/main')

module.exports = App
    
