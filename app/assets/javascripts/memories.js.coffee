jQuery ($)->
  $('.polaroid').each ->
    angles = [-6, -4, -2, 0, 2, 4, 6]
    thisRotation = angles[Math.floor(Math.random()*angles.length)]
    lOrR = if thisRotation < 0 then "left" else "right"
    $(@).addClass "polaroid-pull-#{lOrR}-#{thisRotation}"

  $('.comments-pad').each ->
    angles = ['-15', '-1', '-05', '0', '05', '1', '15']
    thisRotation = angles[Math.floor(Math.random()*angles.length)]
    lOrR = if thisRotation.match(/^-/) then "left" else "right"
    $(@).addClass "comment-pull-#{lOrR}-#{thisRotation}"


  $.widget 'photoboard.liveEdit',
    options:
      map: {}
      toggleOn: ->
      toggleOff: ->
    _create: ->
      @_setupToggles()
      @_runToggleOffs()
      @_setupSubmitWhens()

      $ele = $(@element)
      widget = @
      $ele.on 'submit', (e)->
        e.preventDefault()
        res = $.post $ele.attr('action'), $ele.serializeArray(), null, 'json'
        res.done (data, stats, xhr)->
          for dataKey, value of data
            continue unless widget.options.map[dataKey] # not all data keys have bindings
            mapDataKey = widget.options.map[dataKey]
            for selector in (mapDataKey.selectors or [])
              $(selector, $ele).val value
              $(selector, $ele).text value
            widget._proxy(mapDataKey.afterLoad)() if mapDataKey.afterLoad
        res.fail ()->
          alert "oops, something went wrong, and I couldn't save that."
        res.always ()->
          $ele.trigger 'photoboard.dataLoaded'
          

    _submit: ->
      $(@).trigger 'submit'

    _setupSubmitWhens: ->
      for dataKey, mapData of @options.map
        @_proxy(mapData.submitWhen)(@_proxy(@_submit))
        
    _setupToggles: ->
      for dataKey, mapData of @options.map
        continue unless mapData.toggleOn
        for toggle in (mapData.toggleOnWhen or [])
          @_proxy(toggle)(@_proxy(mapData.toggleOn))

        for toggle in (mapData.toggleOffWhen or [])
          @_proxy(toggle)(@_proxy(mapData.toggleOff))

    _runToggleOffs: ->
      for dataKey, mapData of @options.map
        @_proxy(mapData.toggleOff)() if mapData.toggleOff

    _proxy: (fn)->
      $.proxy fn, @element




  $('.infinite-container').infinteScroll
    scrollReady: ->
      $("[rel='gallery']", this).fancybox()
      $("[data-live-edit]", this).liveEdit
        map:
          marked_for_delete_at:
            submitWhen: (submit)->
              $("[name='memory[marked_for_delete_at]']", $(@)).on 'change', submit

          title:
            selectors: ["[name*='title']", ".memory-title"]
            toggleOnWhen: [
              (toggle)->
                $('.polaroid dt', $(@)).on 'click', toggle
            ]
            toggleOffWhen: [
              (toggle)->
                $('input[type="text"][name*="title"]', $(@)).on 'blur', toggle
              ,(toggle)->
                $(@).on 'photoboard.dataLoaded', toggle
            ]
            submitWhen: (submit)->
              $('input[type="text"][name*="title"]', $(@)).on 'blur', submit
            toggleOn: ->
              $('div.memory-title', $(@)).hide()
              $('input[type="text"]', $(@)).show()
              $('input[type="text"][name*="title"]', $(@)).focus()
            toggleOff: ->
              $('div.memory-title', $(@)).show()
              $('input[type="text"]', $(@)).hide()

          text:
            selectors: [".this-comment > p"]
            toggleOnWhen: [
              (toggle)->
                $(@).on 'click', '.comments-pad.behind', toggle
              ,(toggle)->
                $(@).parents('.memory').find('[href^="#show-comments"]').on 'click', toggle
            ]
            toggleOffWhen: [
              (toggle)->
                # don't let textarea clicks tigger the hide on the parent
                $('.comments-pad:not(.behind) textarea').on 'click', (e)->
                  e.stopPropagation()
                  false
                $(@).on 'click', '.comments-pad:not(.behind)', toggle
            ]
            submitWhen: (submit)->
              $textArea = $('textarea[name*="text"]', $(@))
              $textArea.on 'blur', ()->
                submit(arguments...) if $textArea.val()
            toggleOn: (e)->
              e.preventDefault()
              $(@).find('.comments-pad').removeClass('behind')
              $(@).find('.comments-pad').removeClass('comments-invisible')
              $(@).find('textarea').focus()
            toggleOff: ->
              $(@).find('.comments-pad').addClass('behind')
              if !$(@).find('.user-tag')[1]
                $(@).find('.comments-pad').addClass 'comments-invisible'
            afterLoad: ->
              $('textarea[name*="text"]', $(@)).val('')
              $newEle = $(@).find('.this-comment').clone()
              $('.old-comments', $(@)).append $newEle
              $newEle.find('p').html('')
              $(@).find('.this-comment').eq(0).removeClass('this-comment')
