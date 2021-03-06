import { emoteParse, emoteLoad } from './emote-parser.js'

const urlParams = new URLSearchParams(window.location.search)

export const config = {
  username: urlParams.get('username'),
  notify: {
    chat: urlParams.get('chat') || true,
    subs: urlParams.get('subs') || false,
    subanniversary: urlParams.get('subannv') || false,
    hosts: urlParams.get('hosts') || false,
  },
  maxmessages: urlParams.get('maxmsgs') || 5,
  debug: urlParams.get('debug') || false,
}

function escapeHtml(str) {
  const div = document.createElement('div')
  div.appendChild(document.createTextNode(str))
  return div.innerHTML
}

export let client
export function createClient() {
  if (client) {
    return
  }

  client = new tmi.Client({
    options: {
      debug: !!config.debug,
    },
    connection: {
      random: 'chat',
      reconnect: true,
    },
    channels: ['#' + config.username],
  })

  client.connect()

  client.on('roomstate', (_, state) => emoteLoad(state['room-id']))

  client.addListener('chat', (channel, user, message) => {
    if (config.notify.chat) {
      const event = new CustomEvent('message', {
        detail: {
          user: user,
          message: emoteParse(escapeHtml(message), message, user.emotes),
          action: false,
        },
      })
      document.dispatchEvent(event)
    }
  })

  client.addListener('action', (channel, user, message) => {
    if (config.notify.chat) {
      const event = new CustomEvent('message', {
        detail: {
          user: user,
          message: emoteParse(escapeHtml(message), message),
          action: true,
        },
      })
      document.dispatchEvent(event)
    }
  })

  client.addListener('subscription', (channel, user) => {
    if (config.notify.subs) {
      const event = new CustomEvent('sub', {
        detail: {
          user: user,
        },
      })
      document.dispatchEvent(event)
    }
  })

  client.addListener('subanniversary', (channel, user, months) => {
    if (config.notify.subanniversary) {
      const event = new CustomEvent('subanniversary', {
        detail: {
          user: user,
          months: months,
        },
      })
      document.dispatchEvent(event)
    }
  })

  client.addListener('hosted', (channel, user, viewers) => {
    if (config.notify.hosts) {
      const event = new CustomEvent('host', {
        detail: {
          user: user,
          viewers: viewers,
        },
      })
      document.dispatchEvent(event)
    }
  })

  client.addListener('connected', (address, port) => {
    const event = new CustomEvent('message', {
      detail: {
        user: {
          'display-name': 'Chat Overlay',
        },
        message: 'Connected to twitch.tv!',
        action: false,
      },
    })
    document.dispatchEvent(event)
  })

  client.addListener('disconnected', (reason) => {
    const event = new CustomEvent('message', {
      detail: {
        user: {
          'display-name': 'Chat Overlay',
        },
        message:
          'You have been disconnected from twitch.tv. (Reason: ' +
          reason +
          ').',
        action: false,
      },
    })
    document.dispatchEvent(event)
  })
}
