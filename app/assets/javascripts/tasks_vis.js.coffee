draw_line = (context, from, to) ->
  context.beginPath()
  context.moveTo from[0], from[1] 
  context.lineTo to[0], to[1]
  context.closePath()
  context.stroke()

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
        outer = jQuery("##{task.transaction.identifier}_#{task.state}") 
        unless outer.length > 0
          outer = jQuery('<div>')
            .attr('id', "#{task.transaction.identifier}_#{task.state}")
            .addClass('transaction')
            .html("#{task.queue.name}<br />#{task.transaction.identifier}")
      else
        outer = jQuery("##{task.queue.name}_#{task.state}") 
        unless outer.length > 0
          outer = jQuery('<div>')
            .attr('id', "#{task.queue.name}_#{task.state}")
            .addClass('queue')
            .html("#{task.queue.name}") 
      outer.append box
      outer.appendTo('#' + task.state)

      box.mouseenter do (task, box) ->
        (e) ->
          canvas = jQuery('#dep_canvas').get(0)
          context = canvas.getContext("2d")
          context.lineWidth = 2
          context.strokeStyle = 'gray'
          task.dependency_ids.forEach (dependency) ->
            dep = jQuery("#task_#{dependency}").addClass('highlight')
            box_offset = box.offset()
            dep_offset = dep.offset()
            draw_line context, [box_offset.left + box.outerWidth() - 2, box_offset.top + (box.outerHeight() / 2)], [dep_offset.left, dep_offset.top + (dep.outerHeight() / 2)]
          box.one 'mouseleave', (e) ->
            jQuery('.highlight').removeClass('highlight')
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
          .html(battery.task)
      )
      batatery_div = jQuery('<div>')
        .addClass('battery')
        .appendTo('#batteries')
      segment_width = 248 / battery.capacity
      [0...battery.charge].forEach (seg)->
        batatery_div.append(
          jQuery('<div>')
            .addClass('segment')
            .addClass('charged')
            .css({
              left: seg * segment_width,
              width: "#{segment_width}px"
            })
        )
      [battery.charge...battery.capacity].forEach (seg)->
        batatery_div.append(
          jQuery('<div>')
            .addClass('segment')
            .addClass('empty')
            .css({
              left: seg * segment_width,
              width: "#{segment_width}px"
            })
        )


  setTimeout update_batteries, 10000


jQuery ->
  update_batteries()