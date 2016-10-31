command: 'echo "$(./bar.widget/spaces.sh) | $(/usr/local/bin/kwmc query window focused name)"'

refreshFrequency: 1000 # ms

render: (output) ->
  """
  <link rel="stylesheet" href="./bar.widget/assets/font-awesome/css/font-awesome.min.css" />
  <div class="foc"
    <span></span>
    <span class="icon"></span>
  </div>
  """

update: (output, el) ->
  add3Dots = (str, limit) ->
    dots = "..."
    if str.length > limit
      str = str.substring(0,limit) + dots
    return str

  output = add3Dots output, 80
  $(".foc span:first-child", el).text("  #{output}")
  $icon = $(".foc span.icon", el)
  $icon.removeClass().addClass("icon")
  $icon.addClass("fa fa-bars")

style: """
  -webkit-font-smoothing: antialiased
  color: #d5c4a1
  font: 10px Input
  height: 16px
  left: 10px
  overflow: hidden
  text-overflow: ellipsis
  top: 6px
  width: auto
  white-space: nowrap
"""
