fetch 'config.json'
    .then (response) -> response.json()
    .then (config) ->
        loadEmotes config
        start config

messageQueue = []
allEmotes = {}

loadEmotes = (config) ->
    if config.emotes
        fetch '//twitchemotes.com/global.json'
            .then (response) -> response.json()
            .then (emotes) -> parseTwitchEmotes emotes

    if config.subemotes
        fetch '//twitchemotes.com/subscriber.json'
            .then (response) -> response.json()
            .then (emotes) -> parseTwitchSubEmotes emotes

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

replaceEmotes = (msg) ->
    return msg if not allEmotes

    for emote of allEmotes
        msg = msg.replace new RegExp('\\b' + emote + '\\b', 'g'), urlToImage(allEmotes[emote])

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
