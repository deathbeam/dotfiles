command: 'echo "$(./bar.widget/spaces.sh) | $(/usr/local/bin/kwmc query window focused name)"'

refreshFrequency: 1000 # ms

render: (output) ->
  """
  <div class="foc"
    <span></span>
    <span class="icon fa fa-bars"></span>
  </div>
  """

update: (output, el) ->
  output = @dotted output, 80
  $(".foc span:first-child", el).text("  #{output}")

dotted: (str, limit) ->
  dots = "..."
  if str.length > limit
    str = str.substring(0,limit) + dots
  return str

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
