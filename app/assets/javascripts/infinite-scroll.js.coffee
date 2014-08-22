jQuery ($)->
  # Call it on a container.  The container will load up .infinite-content sections dynamically.  
  # When the user reaches the end of the page infinite scroll will search in the current content page section 
  # for a selector matching a next link the page at that URL be loaded, and after'd the current content page.
  # The reverse happens going up.  The URL is kept in sync with pushState
  #
  # scrollReady() is called on the new content after it's put on page.
  # loadFailure() is called if there's a failure getting the ajax content
  #
  # Depends on the amazing 'waypoints' plugin (http://imakewebthings.com/jquery-waypoints/#doc-waypoint)
  #
  $.widget 'phoneFiction.infinteScroll',
    options:
      contentSelector:          ".infinite-content"
      nextLinkSelector:         "a[rel='next']:contains('Next')"
      previousLinkSelector:     "a[rel='prev']:contains('Prev')"
      navigationSelector:       "nav"
      infPrevNavAttr:           "data-infinite-prev-nav"
      infNextNavAttr:           "data-infinite-next-nav"
      linkExhaustedAttr:        "data-infinite-exhausted"
      infURLAttr:               "data-infinite-url"
      hiddenNavClass:           "infinite-invisible"
      loadingClass:             "infinite-loading"
      previousOffset:           100
      nextOffset:               '100%'
      idPrefix:                 'inf-'
      scrollReady: ()-> #the context is your new content
      loadFailure: ()-> #the context is the widgets element

    _create: ->
      @bothLinksSelector = "#{@options.nextLinkSelector}, #{@options.previousLinkSelector}"
      # Initialization is a special case, where we need to have possibly both Up and Down added to the 
      # page.  compound on that, the fact that we're mainulating the acutal DOM, and not a fragment.
      $newContent = @_concatDownContent $('body')
      @_setInfURL $newContent, window.location, $newContent
      $clone = $('body').clone()
      $(@options.navigationSelector).remove()
      @_concatUpNav $clone.clone()
      @_concatDownNav $clone.clone()
      @_setupAjaxWaypoints()
      $.proxy(@options.scrollReady, $newContent)()

    _loadContent: ($navEle, concatFcn)->
      $.waypoints('disable')
      widget = @
      url = $navEle.attr("href")
      request = $.get url
      @_addLoader $navEle

      request.done (data, textStatus, jqXHR)->
        $newContent = concatFcn $('<div>').append(data)
        widget._setInfURL $newContent, @url, $newContent.next()
        widget._destroyWaypoints()
        widget._setupHistoryWaypoints()
        widget._setupAjaxWaypoints()
        $.proxy(widget.options.scrollReady, $newContent)()
      request.always @_bind(widget._afterLoadAlways)
      request.fail @_bind(widget.loadFailure)

    _setInfURL: ($ele, url, $hashEle=null)->
      $ele.attr @options.infURLAttr, url
      $ele.attr 'id', @options.idPrefix + (new Date).getTime()
      @_setHistoryState $ele, $hashEle

    _setHistoryState: ($ele, $hashEle=null)->
      # Move to the hash, but then we're going to replace the url with something clean
      # The hash are just a tick to get top-loaded content to work, and they had the 
      # plesent side effect of allowing top-scroll on the first element without the
      # user having to scroll down, and then back up again
      if $hashEle && $hashEle.attr('id')
        window.location.hash = $hashEle.attr('id')
      if window.history #non-html5 browsers can just deal with one long-ass page
        window.history.replaceState {}, document.title, $ele.attr(@options.infURLAttr)

    _newContent: ($scope)->
      $scope.find @options.contentSelector

    _addLoader: ($navEle)->
      $loader = $('<div>')
      $loader.addClass @options.loadingClass
      $navEle.parents(@options.navigationSelector).after($loader)

    _removeLoader: ->
      $('.'+@options.loadingClass).remove()

    _afterLoadAlways: ->
      $.waypoints('enable')
      @_removeLoader()

    _concatUpContent: ($scope)->
      @_newContent($scope).prependTo $(@element)

    _concatUpNav: ($scope, keepNext = false)->
      $(@options.nextLinkSelector, $scope).remove() unless keepNext
      $(@element).before @_buildNewNav($scope, @options.infNextNavAttr, @options.infPrevNavAttr)

    _concatDownContent: ($scope)->
      @_newContent($scope).appendTo $(@element)

    _concatDownNav: ($scope, keepPrev = false)->
      $(@options.previousLinkSelector, $scope).remove() unless keepPrev
      $(@element).after @_buildNewNav($scope, @options.infPrevNavAttr, @options.infNextNavAttr)

    _buildNewNav: ($scope, removeAttr, addAttr)->
      $newNav = $scope.find(@options.navigationSelector)
      $newNav.addClass @options.hiddenNavClass
      $newNav.removeAttr(removeAttr)
      # if this new nav doesn't have one of the two link selectors, then we know that
      # we're not going to be loading anymore content.  So lets mark it
      if !$newNav.has(@bothLinksSelector)[0]
        $newNav.attr(@options.linkExhaustedAttr, true)

      $newNav.attr(addAttr, true)

    _setupHistoryWaypoints: ->
      widget = @
      $(widget.options.contentSelector).each (idx, ele)->
        $(ele).waypoint
          offset: 0
          handler: ->
            widget._setHistoryState $(ele)

    _setupAjaxWaypoints: ->
      widget = @
      $(@options.nextLinkSelector).waypoint
        offset: @options.nextOffset
        handler: (direction)->
          if direction == "down"
            concatFcn = widget._bind ($scope)->
              widget._removeWaypointHandle(@options.infNextNavAttr)
              widget._concatDownNav($scope)
              widget._concatDownContent($scope)
            widget._loadContent $(@), concatFcn

      $(@options.previousLinkSelector).waypoint
        offset: @options.previousOffset
        handler: (direction)->
          if direction == "up"
            concatFcn = widget._bind ($scope)->
              widget._removeWaypointHandle(@options.infPrevNavAttr)
              widget._concatUpNav($scope)
              widget._concatUpContent($scope)
            widget._loadContent $(@), concatFcn

    _destroyWaypoints: ->
      $.waypoints('destroy')

    _removeWaypointHandle: (attr)->
      $(@options.navigationSelector).filter("[#{attr}]").remove()

    _bind: (fcn)->
      $.proxy(fcn, @)




