# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

update = ->
  jQuery.getJSON '/tasks', (data) ->
    jQuery('#tasks tbody tr').remove()
    for task in data
      console.log task
      jQuery('#tasks tbody')
      .append jQuery('<tr>')
        .append(jQuery('<td>').html(task.queue.name))
        .append(jQuery('<td>').html(task.sku))
        .append(jQuery('<td>').html(task.operation_type))
        .append(jQuery('<td>').html(task.transaction?.identifier ? ''))
        .append(jQuery('<td>').html(task.index ? ''))
        .append(jQuery('<td>').html(task.state))

  setTimeout update, 10000

jQuery ->
  update()
  