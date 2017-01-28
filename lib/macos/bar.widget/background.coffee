refreshFrequency: false

render: (output) ->
  """
  <link rel="stylesheet" href="./bar.widget/assets/font-awesome/css/font-awesome.min.css" />
  <style type="text/css">
  html, body {
    font-family: "Terminus", system, -apple-system;
    font-size: 12px;
    color: #dfe1e8;
  }
  </style>
  """

style: """
  top: 0
  left: 0
  height: 25px
  width: 100%
  z-index: -1
  background: #2b303b;
"""
