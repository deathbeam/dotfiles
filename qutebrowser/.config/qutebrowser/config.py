# Adjust font and font size
c.fonts.completion.category = "bold 16pt monospace"
c.fonts.completion.entry = "16pt monospace"
c.fonts.debug_console = "16pt monospace"
c.fonts.downloads = "16pt monospace"
c.fonts.hints = "16pt monospace"
c.fonts.keyhint = "16pt monospace"
c.fonts.messages.error = "16pt monospace"
c.fonts.messages.info = "16pt monospace"
c.fonts.messages.warning = "16pt monospace"
c.fonts.monospace = "\"xos4 Terminus\", Terminus, monospace"
c.fonts.prompts = "16pt sans-serif"
c.fonts.statusbar = "16pt monospace"
c.fonts.tabs = "16pt monospace"

# Play videos with mpv
config.bind('e', 'spawn mpv {url}')
config.bind('E', 'hint links spawn mpv {hint-url}')
