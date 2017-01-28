command: "date +\"%H:%M\""

refreshFrequency: 10000 # ms

render: (output) ->
  """
  <div class="time">
    <span></span>
    <span class="icon fa fa-clock-o"></span>
  </div>
  """

update: (output, el) ->
  $(".time span:first-child", el).text("  #{output}")

style: """
  right: 10px
  top: 6px
"""
