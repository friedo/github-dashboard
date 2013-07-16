sMap = {
  "0": { color: 'white', backgroundColor: 'red' },
  "2": { color: 'black', backgroundColor: 'yellow' },
  "4": { color: 'white', backgroundColor: 'green' },
  "8": { color: 'white', backgroundColor: 'gray' }
}

class Dashing.Jenkins extends Dashing.Widget

  @accessor 'Last_Success_fromNow', ->
    moment(@get('Last_Success')).fromNow()

  @accessor 'Last_Failure_fromNow', ->
    moment(@get('Last_Failure')).fromNow()

  @accessor 'Last_Duration_humanize', ->
    moment.duration(parseInt(@get('Last_Duration'))).humanize()

  color: ->
    buildColors = sMap[@get('S')] || { color: 'white', backgroundColor: '#999' }
    $(@node).css('color',buildColors['color'])
    $(@node).fadeOut().css('background-color',buildColors['backgroundColor']).fadeIn()

  paint: ->
    this.color()
    $(@node).find('.health').html("<img class=\"icon32x32\" src=\"#{@get('W')}\" alt=\"health icon\">")

  ready: ->
    this.paint()

  onData: (data) ->
   if data.currentResult isnt data.lastResult
     this.paint()

