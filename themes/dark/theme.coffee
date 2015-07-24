fetch 'config.json'
    .then (response) -> response.json()
    .then (config) -> start config

messageQueue = []

start = (config) ->
    socket = io 'ws://localhost:' + (config.port || 1337), transports: ['websocket', 'polling']

    socket.on 'message', (data) ->
        messageQueue.push data

appendMessage = (data) ->
    template = """
        <div class="name">#{data.user.username}</div>
        <div class="msg">#{data.message}</div>
    """

    $row = document.createElement 'li'
    $row.style.borderColor = data.user.color
    $row.innerHTML = template

    document.querySelector('.messages').appendChild $row

messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000
