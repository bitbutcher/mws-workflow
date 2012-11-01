draw_line = (context, from, to) ->
  context.beginPath()
  context.moveTo from.x, from.y
  context.lineTo to.x, to.y
  head_len = 10
  angle = Math.atan2 to.y - from.y, to.x - from.x
  context.lineTo to.x - head_len * Math.cos(angle - Math.PI / 6), to.y - head_len * Math.sin(angle - Math.PI / 6)
  context.moveTo to.x, to.y
  context.lineTo to.x - head_len * Math.cos(angle + Math.PI / 6), to.y - head_len * Math.sin(angle + Math.PI / 6)

  context.closePath()
  context.stroke()

determine_anchors = (from, to) ->
  if from.y > to.y and to.x <= from.x
    [
      { 
        x: from.x + from.width / 2, 
        y: from.y
      },
      { 
        x: to.x + to.width / 2, 
        y: to.y + to.height
      }
    ]
  else
    [
      {
        x: from.x + from.width, 
        y: from.y + (from.height / 2)
      }, 
      { 
        x: to.x, 
        y: to.y + (to.height / 2)
      }
    ]
    
update = ->
  jQuery.getJSON '/tasks', (data) ->
    jQuery('.task, .transaction, .queue').remove()
    for task in data
      box = jQuery('<div>')
        .attr('id', "task_#{task.id}")
        .addClass('task')
        .addClass(task.state)
        .html(task.sku + '<br/>' + task.operation_type)
      if task.transaction?
        outer = jQuery "##{task.transaction.identifier}_#{task.state}"
        unless outer.length > 0
          outer = jQuery('<div>')
            .attr('id', "#{task.transaction.identifier}_#{task.state}")
            .addClass('transaction')
            .html("#{task.queue.name}<br />#{task.transaction.identifier}")
      else
        outer = jQuery "##{task.queue.name}_#{task.state}"
        unless outer.length > 0
          outer = jQuery('<div>')
            .attr('id', "#{task.queue.name}_#{task.state}")
            .addClass('queue')
            .html("#{task.queue.name}") 
      outer.append box
      outer.appendTo "##{task.state} > .viewport"

      box.mouseenter do (task, box) ->
        (e) ->
          canvas = jQuery('#dep_canvas').get(0)
          context = canvas.getContext '2d'
          context.lineWidth = 2
          context.strokeStyle = 'gray'
          task.dependency_ids.forEach (dependency) ->
            dep = jQuery("#task_#{dependency}").addClass 'highlight'
            draw_line context, determine_anchors(
              { 
                x: box.offset().left, 
                y:box.offset().top, 
                width: box.outerWidth(), 
                height: box.outerHeight()
              }, 
              {
                x: dep.offset().left, 
                y: dep.offset().top, 
                width: dep.outerWidth(), 
                height: dep.outerHeight()
              }
            )...

          box.one 'mouseleave', (e) ->
            jQuery('.highlight').removeClass 'highlight'
            context.clearRect 0, 0, canvas.width, canvas.height

  jQuery('#dep_canvas')
    .attr({
      width: jQuery('#cols').width(),
      height: jQuery('#cols').height()
    })
  setTimeout update, 10000

jQuery ->
  update()

update_batteries = ->
  jQuery.getJSON '/batteries', (data) ->
    jQuery('.battery, .label').remove()
    data.forEach (battery) ->
      jQuery('#batteries').append(
        jQuery('<span>')
          .addClass('label')
          .html(battery.device)
      )
      battery_div = jQuery('<div>')
        .addClass('battery')
        .appendTo('#batteries')
      charge = battery.charge / battery.capacity * 100
      if charge > 50
        charge_class = 'high' 
      else if charge > 25
        charge_class = 'medium' 
      else
        charge_class = 'low'

      battery_div
      .append(
        jQuery('<div>')
          .addClass('segment')
          .addClass(charge_class)
          .css(width: "#{charge}%")
      )
      .append(
        jQuery('<div>')
          .addClass('nipple')
      )

  setTimeout update_batteries, 10000

jQuery ->
  update_batteries()