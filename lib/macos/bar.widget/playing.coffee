# command: 'username=' + 'tomasslusny' + '; curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getRecentTracks&user=$username&api_key=b25b959554ed76058ac220b7b2e0a026&format=json&limit=1"'
command: 'echo $(cat $HOME/.currentsong/song.txt)'
refreshFrequency: 1000 # ms

render: (output) ->
  """
  <div class="np"
    <span></span>
    <span class="icon fa fa-play-circle-o"></span>
  </div>
  """

update: (output, el) ->
    # data = JSON.parse(output)
    # artist = data.recenttracks.track[0].artist["#text"]
    # song = data.recenttracks.track[0].name
    # output = "#{song} - #{artist}"
    $(".np span:first-child", el).text("  #{output}")

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
