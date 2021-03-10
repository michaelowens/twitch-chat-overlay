import { createClient } from '/js/chat.js'

createClient()

document.addEventListener('message', (data) => appendMessage(data.detail))

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
    <span class="user" style="color: ${data.user.color};">${data.user['display-name']}</span>:
    <span class="msg">${data.message}</span>`

  $row.addEventListener('animationend', () => $row.parentNode.removeChild($row))
  document.querySelector('.messages').appendChild($row)
}
