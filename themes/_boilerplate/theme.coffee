fetch 'config.json'
    .then (response) -> response.json()
    .then (config) -> start config

messageQueue = []

start = (config) ->
    socket = io 'ws://localhost:' + (config.port || 1337), transports: ['websocket', 'polling']

    socket.on 'message', (data) ->
        messageQueue.push data

    socket.on 'subscription', (data) ->
        console.log data.user + ' just subscribed!'

    socket.on 'subanniversary', (data) ->
        console.log data.user.username + ' subbed for ' + data.months + ' month' + (if data.months isnt 1 then 's' else '') + '!'

appendMessage = (data) ->
    template = """
        <div class="name">#{data.user.username}</div>
        <div class="msg">#{data.message}</div>
    """

    $row = document.createElement 'li'
    $row.innerHTML = template

    document.querySelector('.messages').appendChild $row

messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000