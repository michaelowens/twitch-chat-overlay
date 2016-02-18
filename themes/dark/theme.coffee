messageQueue = []

document.addEventListener 'message', (data) ->
    messageQueue.push data.detail # CustomEvents use the .detail field

paddedTime = (str) -> if str.length < 2 then '0' + str else str

appendMessage = (data) ->
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

    document.querySelector('.messages').appendChild $row

messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000
