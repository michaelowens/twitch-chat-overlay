messageQueue = []

document.addEventListener 'message', (data) ->
    messageQueue.push data.detail # CustomEvents use the .detail field

document.addEventListener 'subscription', (data) ->
    console.log data.user + ' just subscribed!'

document.addEventListener 'subanniversary', (data) ->
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