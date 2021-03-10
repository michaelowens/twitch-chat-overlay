let messageQueue = []

document.addEventListener('message', (data) => {
  messageQueue.push(data.detail)
})

document.addEventListener('subscription', (data) => {
  console.log(data.user + ' just subscribed!')
})

document.addEventListener('subanniversary', (data) => {
  console.log(
    data.user['display-name'],
    'subbed for',
    data.months,
    ' month' + (data.months !== 1 ? 's' : '') + '!'
  )
})

function appendMessage(data) {
  const $row = document.createElement('li')
  $row.innerHTML = `
    <div class="name">${data.user['display-name']}</div>
    <div class="msg">${data.message}</div>`
  document.querySelector('.messages').appendChild($row)
}

function messageLoop() {
  if (messageQueue.length > 0) {
    appendMessage(messageQueue.shift())
  }
}

setInterval(messageLoop, 250)
