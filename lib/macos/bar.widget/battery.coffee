command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 15000 # ms

render: (output) ->
  """
  <div class="battery">
    <span></span>
    <span class="icon fa fa-baterry-empty"></span>
  </div>
  """

update: (output, el) ->
    $(".battery span:first-child", el).text("  #{output}")
    elIcon = $(".battery span.icon", el)
    elIcon.removeClass().addClass("icon fa #{@icon(parseInt(output))}")

icon: (output) =>
  return if output > 90
    "fa-battery-full"
  else if output > 70
    "fa-battery-three-quarters"
  else if output > 40
    "fa-battery-half"
  else if output > 20
    "fa-battery-quarter"
  else
    "fa-battery-empty"

style: """
  top: 7px
  right: 160px
"""
