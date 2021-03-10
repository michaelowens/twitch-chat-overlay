import { config, createClient } from '/js/chat.js'

createClient()

let messageQueue = []

document.addEventListener('message', (data) => messageQueue.push(data.detail))

function safeMessage(str) {
  const div = document.createElement('div')
  div.appendChild(document.createTextNode(str))
  return div.innerHTML
}

function appendMessage(data) {
  const $nonHidden = document.querySelectorAll('.messages > li:not(.hidden)')
  if ($nonHidden.length >= config.maxmessages) {
    console.log('remove hidden')
    $nonHidden.forEach(($el) => $el.classList.add('hidden'))
  }

  const now = new Date()
  const h = now.getHours().toString().padStart(2, '0')
  const m = now.getMinutes().toString().padStart(2, '0')

  const $row = document.createElement('li')
  $row.style.borderColor = data.user.color
  $row.innerHTML = `
    <div class="name">${data.user['display-name']}</div>
    <div class="time">${h}:${m}</div>
    <div class="msg">${data.message}</div>`

  const $messages = document.querySelector('.messages')
  $messages.appendChild($row)
  $messages.style.bottom = '-' + ($row.offsetHeight + 1) + 'px'

  setTimeout(() => {
    $messages.classList.add('animated')
    $messages.style.bottom = 0
  })

  setTimeout(() => {
    $messages.classList.remove('animated')
  }, 900)
}

function messageLoop() {
  if (messageQueue.length > 0) {
    appendMessage(messageQueue.shift())
  }
}

setInterval(messageLoop, 1000)
