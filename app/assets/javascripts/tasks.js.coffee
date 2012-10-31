# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.tasks = 
  update_callback: -> 
    jQuery('#tasks tbody tr').remove()
  handler: (task) ->
    jQuery('#tasks tbody')
      .append jQuery('<tr>')
        .append(jQuery('<td>').html(task.queue_name))
        .append(jQuery('<td>').html(task.sku))
        .append(jQuery('<td>').html(task.operation))
        .append(jQuery('<td>').html(task.transaction))
        .append(jQuery('<td>').html(task.message))
        .append(jQuery('<td>').html(task.state))

update = ->
  jQuery.getJSON '/tasks', (data) ->
    tasks.update_callback()
    for task in data
      tasks.handler 
        id: task.id,
        queue_name: task.queue.name,
        sku: task.sku,
        operation: task.operation_type,
        transaction: task.transaction?.identifier || '',
        message: task.index || '',
        state: task.state
  setTimeout update, 10000

jQuery ->
  update()
  