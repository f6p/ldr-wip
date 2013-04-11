$ ->
  if $('.suggestions').length > 0
    $.get '/games/suggestions', (list) ->
      $('.suggestions .wait').replaceWith list
