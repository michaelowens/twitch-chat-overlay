import { config, createClient } from '/js/chat.js'

createClient()

document.addEventListener('message', (data) => appendMessage(data.detail))

function appendMessage(data) {
  const $nonHidden = document.querySelectorAll('.messages > li:not(.hidden)')
  if ($nonHidden.length >= config.maxmessages) {
    const $el = $nonHidden[0]
    $el.classList.add('hidden')
    $el.addEventListener('animationend', () => $el.remove())
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
}
