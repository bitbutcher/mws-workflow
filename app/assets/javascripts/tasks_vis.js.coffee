#= require jade

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
    
task_template = jade.compile '''
  - var icons = {update: 'arrow-up', delete: 'remove'}
  .task(id="task_#{id}", class=state)
    i(class="icon-#{icons[operation_type]}")
    span=sku
'''

transaction_template = jade.compile '''
  .transaction(id="#{transaction.identifier}_#{state}")
    div=queue.name
    div=transaction.identifier
'''

queue_template = jade.compile '''
  .queue(id="#{queue.name}_#{state}")
    div=queue.name
'''

modal_body_template = jade.compile '''
  pre.prettyprint=body
  .failure=failure
'''


update = ->
  jQuery.getJSON '/tasks', (data) ->
    jQuery('.task, .transaction, .queue').remove()
    for task in data
      box = jQuery(task_template(task))
        .click do(task) -> 
          (e) ->
            modal = jQuery('#task_modal')
            modal.find('.title').html "#{task.sku} - #{task.operation_type}"
            body = modal.find('.modal-body').html('<img src="/assets/ajax-loader.gif"/>')
            modal.modal('toggle')
            jQuery.getJSON "/tasks/#{task.id}", (task) ->
              body.html modal_body_template(task)
              
      if task.transaction?
        outer = jQuery "##{task.transaction.identifier}_#{task.state}"
        unless outer.length > 0
          outer = jQuery transaction_template(task)
      else
        outer = jQuery "##{task.queue.name}_#{task.state}"
        unless outer.length > 0
          outer = jQuery queue_template(task)
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


battery_template = jade.compile '''
  span.label=device
  .battery
    .charge(class=charge.class, style="width: #{charge.percent}%")
    .nipple
'''

class_for = (percent) ->
  return 'high' if percent > 50
  return 'medium' if percent > 25
  return 'low'

charge_for = (battery) ->
  percent = battery.charge / battery.capacity * 100 
  amount: battery.charge
  percent: percent
  class: class_for percent

update_batteries = ->
  jQuery.getJSON '/batteries', (data) ->
    jQuery('.battery, .label').remove()
    data.forEach (battery) ->
      battery.charge = charge_for battery
      jQuery(battery_template(battery)).appendTo('#batteries')

  setTimeout update_batteries, 10000

jQuery ->
  update_batteries()