fetch('config.json')
  .then((response) => response.json())
  .then((config) => start(config))

let messageQueue = []

function start(config) {
  const socket = io('ws://' + document.domain + ':' + (config.port || 1337), {
    transports: ['websocket', 'polling'],
  })
  socket.on('message', (data) => messageQueue.push(data))
  socket.on('subscription', (data) =>
    console.log(data.user + ' just subscribed!')
  )
  socket.on('subanniversary', (data) => {
    console.log(
      data.user.username +
        ' subbed for ' +
        data.months +
        ' month' +
        (data.months !== 1 ? 's' : '') +
        '!'
    )
  })
}

function appendMessage(data) {
  const oldMessages = document.querySelector('.message')
  if (oldMessages) {
    oldMessages.parentNode.removeChild(oldMessages)
  }

  const now = new Date()
  const h = now.getHours().toString().padStart(2, '0')
  const m = now.getMinutes().toString().padStart(2, '0')

  const $row = document.createElement('div')
  $row.className = 'message'
  $row.innerHTML = `
    <span class="time">${h}:${m}</span>
    <span class="user" style="color: ${data.user.color};">${data.user.username}</span>:
    <span class="msg">${data.message}</span>`
  document.querySelector('.messages').appendChild($row)
}

function messageLoop() {
  if (messageQueue.length > 0) {
    appendMessage(messageQueue.shift())
  }
}

setInterval(messageLoop, 1000)
