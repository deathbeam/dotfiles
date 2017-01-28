command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  """
  <div class="cal">
    <span></span>
    <span class="icon fa fa-calendar"></span>
  </div>
  """

update: (output, el) ->
  $(".cal span:first-child", el).text("  #{output}")

style: """
  right: 70px
  top: 6px
"""
