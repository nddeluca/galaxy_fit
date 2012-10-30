Spine = require('spine')

class ResidualImage extends Spine.Model
  @configure 'ResidualImage','width','height','context','funcData','imageData'

  contructor: (@width,@height,@context,@funcData,@imageData) ->
    super
  
module.exports = ResidualImage
