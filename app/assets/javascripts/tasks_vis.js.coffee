#= require "tasks"

tasks.update_callback = ->
  jQuery('.task').remove()
  jQuery('.transaction').remove()

tasks.handler = (task) ->
  box = jQuery('<div>')
    .attr('id', "task_#{task.id}")
    .addClass('task')
    .addClass(task.state)
    .html(task.sku + '<br/>' + task.operation)

  # console.log "Deps: #{task.dependencies}"
  # if task.dependencies?.length > 0
  #   console.log "Deps: #{task.dependencies}"

  if !!task.transaction
    outer = jQuery("\##{task.transaction}_#{task.state}") 
    unless outer.length > 0
      outer = jQuery('<div>')
        .attr('id', "#{task.transaction}_#{task.state}")
        .addClass('transaction')
        .html("#{task.queue_name}<br />#{task.transaction}")
  else
    outer = jQuery("\##{task.queue_name}_#{task.state}") 
    unless outer.length > 0
      outer = jQuery('<div>')
        .attr('id', "#{task.queue_name}_#{task.state}")
        .addClass('queue')
        .html("#{task.queue_name}") 
  outer.append box
  outer.appendTo('#' + task.state)