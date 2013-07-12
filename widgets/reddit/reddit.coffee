class Dashing.Reddit extends Dashing.Widget
  ready: ->
    @currentIndex = 0
    @titleElem = $(@node).find('.subreddit-title')
    @dataElem = $(@node).find('.subreddit-data')
    @top_posts = @get('posts')
    @nextSubreddit()
    @startCarousel()

  onData: (data) ->
    @currentIndex = 0

  startCarousel: ->
    setInterval(@nextSubreddit, 8000)

  nextSubreddit: =>
    if @top_posts
      @dataElem.fadeOut =>
        @set 'posts', @top_posts[@currentIndex]
        @titleElem.fadeIn()
        @dataElem.fadeIn()
        @currentIndex = (@currentIndex + 1) % @top_posts.length