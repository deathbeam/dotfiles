# command: 'username=' + 'tomasslusny' + '; curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getRecentTracks&user=$username&api_key=b25b959554ed76058ac220b7b2e0a026&format=json&limit=1"'
command: 'echo $(cat $HOME/.currentsong/song.txt)'
refreshFrequency: 1000 # ms

render: (output) ->
  # this is a bit of a hack until jQuery UI is included natively
  # $.getScript "https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js"

  """
  <link rel="stylesheet" href="./bar.widget/assets/font-awesome/css/font-awesome.min.css" />
  <div class="np"
    <span></span>
    <span class="icon"></span>
  </div>
  """

update: (output, el) ->
    # data = JSON.parse(output)
    # artist = data.recenttracks.track[0].artist["#text"]
    # song = data.recenttracks.track[0].name
    # output = "#{song} - #{artist}"
    $(".np span:first-child", el).text("  #{output}")
    $icon = $(".np span.icon", el)
    $icon.removeClass().addClass("icon")
    $icon.addClass("fa #{@icon(output)}")

icon: (status) =>
    # return if status.substring(0, 9) == "[stopped]"
    #     "fa-stop-circle-o"
    # else if status.substring(0, 8) == "[paused]"
    #     "fa-pause-circle-o"
    # else if status.substring(0, 17) == "Connection failed"
    #     "fa-times-circle-o"
    # else
    "fa-play-circle-o"

style: """
  -webkit-font-smoothing: antialiased
  text-align: center
  color: #d5c4a1
  font: 10px Input
  height: 16px
  left: 25%
  overflow: hidden
  text-overflow: ellipsis
  top: 6px
  width: 50%
"""
