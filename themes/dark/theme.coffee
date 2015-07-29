fetch 'config.json'
    .then (response) -> response.json()
    .then (config) ->
        loadEmotes config
        start config

messageQueue = []
allEmotes = {}

# This emote logic should really be moved to app.coffee
# would suck having to do this on every theme
loadEmotes = (config) ->
    if config.emotes
        fetchEmoteUrl '//twitchemotes.com/global.json', parseTwitchEmotes

    if config.subemotes
        fetchEmoteUrl '//twitchemotes.com/subscriber.json', parseTwitchSubEmotes

    if config.bttvemotes
        fetchEmoteUrl 'https://api.betterttv.net/2/emotes', parseBTTVEmotes
        fetchEmoteUrl 'https://api.betterttv.net/2/channels/' + config.username, parseBTTVEmotes

fetchEmoteUrl = (url, cb) ->
    fetch url
        .then (response) -> response.json()
        .then (emotes) -> cb.call null, emotes

start = (config) ->
    socket = io 'ws://localhost:' + (config.port || 1337), transports: ['websocket', 'polling']

    socket.on 'message', (data) ->
        messageQueue.push data

parseTwitchEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) -> allEmotes[k] = emotes[k].url

parseTwitchSubEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) ->
        Object.keys(emotes[k].emotes).forEach (k2) ->
            allEmotes[k2] = emotes[k].emotes[k2]

parseBTTVEmotes = (data) ->
    data.emotes.forEach (emote) ->
        allEmotes[emote.code] = parseBTTVURL data.urlTemplate, emote

parseBTTVURL = (tpl, emote) ->
    tpl
        .replace /{{id}}/, emote.id
        .replace /{{image}}/, '1x'

# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
escapeRegExp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

replaceEmotes = (msg) ->
    return msg if not allEmotes

    for emote of allEmotes
        # if emote is '(ditto)' then debugger
        console.log emote
        msg = msg.replace new RegExp('(?!\S)' + escapeRegExp(emote) + '(?!\S)', 'g'), urlToImage(allEmotes[emote])

    return msg # I don't want this

urlToImage = (url) -> '<img src="' + url + '">'

paddedTime = (str) -> if str.length < 2 then '0' + str else str

appendMessage = (data) ->
    msg = replaceEmotes data.message
    now = new Date
    h = paddedTime now.getHours()
    m = paddedTime now.getMinutes()
    time = h + ':' + m
    template = """
        <div class="name">#{data.user.username}</div>
        <div class="time">#{time}</div>
        <div class="msg">#{msg}</div>
    """

    $row = document.createElement 'li'
    $row.style.borderColor = data.user.color
    $row.innerHTML = template

    document.querySelector('.messages').appendChild $row

messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000
