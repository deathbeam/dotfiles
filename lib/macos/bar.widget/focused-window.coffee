command: './bar.widget/spaces.sh'

refreshFrequency: 500 # ms

render: (output) ->
  """
  <style>
  .active {
    color: #268bd2;
  </style>
  <div class="foc">
    <span></span>
    <span class="icon fa fa-bars"></span>
  </div>
  """

update: (output, el) ->
  output = @dotted output, 80
  $(".foc span:first-child", el).html("  #{output}")

dotted: (str, limit) ->
  dots = "..."
  if str.length > limit
    str = str.substring(0,limit) + dots
  return str

style: """
  height: 16px
  left: 10px
  top: 6px
"""
