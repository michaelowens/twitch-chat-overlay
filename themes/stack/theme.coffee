messageQueue = []
config = null

fetch 'config.json'
    .then (response) -> response.json()
    .then (data) ->
        config = data
        start config

start = (config) ->
    socket = io 'ws://localhost:' + (config.port || 1337), transports: ['websocket', 'polling']

    socket.on 'message', (data) ->
        messageQueue.push data

paddedTime = (str) -> if str.length < 2 then '0' + str else str

safeMessage = (str) ->
    # If there's more than the maximum, remove the top of the stack

    div = document.createElement 'div'
    div.appendChild document.createTextNode str
    div.innerHTML

appendMessage = (data) ->
    if document.querySelectorAll('.messages > li:not(.hidden)').length == config.maxmessages
        document.querySelector('.messages > li:not(.hidden)').className += ' hidden'

    now = new Date
    h = paddedTime now.getHours().toString()
    m = paddedTime now.getMinutes().toString()
    time = h + ':' + m
    template = """
        <div class="name">#{data.user.username}</div>
        <div class="time">#{time}</div>
        <div class="msg">#{data.message}</div>
    """

    $row = document.createElement 'li'
    $row.style.borderColor = data.user.color
    $row.innerHTML = template

    $messages = document.querySelector '.messages'
    $messages.appendChild $row

    $messages.style.bottom = '-' + ($row.offsetHeight + 1) + 'px'

    setTimeout ->
        $messages.className += ' animated'
        $messages.style.bottom = 0

    setTimeout ->
        $messages.className = $messages.className.replace ' animated', ''
    , 900


messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000
