fetch 'config.json'
    .then (response) -> response.json()
    .then (config) -> start config

messageQueue = []

start = (config) ->
    socket = io 'ws://' + document.domain + ':' + (config.port || 1337), transports: ['websocket', 'polling']

    socket.on 'message', (data) ->
        messageQueue.push data

    socket.on 'subscription', (data) ->
        console.log data.user + ' just subscribed!'

    socket.on 'subanniversary', (data) ->
        console.log data.user.username + ' subbed for ' + data.months + ' month' + (if data.months isnt 1 then 's' else '') + '!'


paddedTime = (str) -> if str.length < 2 then '0' + str else str

appendMessage = (data) ->
    # It is a ticker, remove old messages
    oldMessages = document.querySelector(".message")
    if oldMessages
        oldMessages.parentNode.removeChild(oldMessages)

    # Time stuff from dark theme
    now = new Date
    h = paddedTime now.getHours().toString()
    m = paddedTime now.getMinutes().toString()
    time = h + ':' + m

    template = """
        <span class="time">#{time}</span>
        <span class="user" style="color: #{data.user.color};">#{data.user.username}</span>:
        <span class="msg">#{data.message}</span>
    """

    $row = document.createElement 'div'
    $row.className = 'message'
    $row.innerHTML = template

    document.querySelector('.messages').appendChild $row

messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000