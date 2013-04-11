$ ->
  $('a[href=#top]').click (event) ->
    event.preventDefault()
    $('html').animate {scrollTop: 0}, 'slow'

  $('.reset').click (event) ->
    event.preventDefault()
    form = $(this).closest('form')

    form.find('input[type=text], textarea').val('')
    form.find('select').prop('selectedIndex', 0)
