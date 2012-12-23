$ = jQuery
$.objectSize = (obj) ->
  count = 0
  for k in obj
    if obj.hasOwnProperty k
      count++
  return count

