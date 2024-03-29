const urlParams = new URLSearchParams(window.location.search)
let allEmotes = []

export const config = {
  username: urlParams.get('username'),
  emotes: urlParams.get('emotes') || true,
  // subemotes: urlParams.get('subemotes') || false,
  // bttvemotes: urlParams.get('bttvemotes') || false,
}

export function emoteParse(msg, unsafeMsg, emotes) {
  let msgEmotes
  if (emotes && config.emotes) {
    // Message had emotes from Twitch
    msgEmotes = Object.keys(emotes).map((id) => {
      const [start, end] = emotes[id][0].split('-').map((n) => parseInt(n))
      return {
        code: unsafeMsg.substring(start, end + 1),
        url: `https://static-cdn.jtvnw.net/emoticons/v1/${id}/1.0`,
      }
    })
    msgEmotes = msgEmotes.concat(allEmotes)
  }

  return replaceEmotes(msg.split(' '), msgEmotes || allEmotes)
}

export function emoteLoad(roomId) {
  if (config.emotes) {
    // fetchEmotes(
    //   'https://api.twitchemotes.com/api/v4/channels/0',
    //   parseTwitchEmotes
    // )
    // fetchEmotes(
    //   'https://api.twitchemotes.com/api/v4/channels/' + roomId,
    //   parseTwitchEmotes
    // )

    fetchEmotes(
      'https://api.betterttv.net/3/cached/emotes/global',
      parseBTTVEmotes
    )
    fetchEmotes(
      'https://api.betterttv.net/3/cached/users/twitch/' + roomId,
      parseBTTVEmotes
    )
    fetchEmotes('https://api.7tv.app/v2/emotes/global', parse7TVEmotes)
    fetchEmotes(`https://api.7tv.app/v2/users/${roomId}/emotes`, parse7TVEmotes)
  }
}

async function fetchEmotes(url, callback) {
  try {
    const response = await fetch(url)
    callback(await response.json())
  } catch (_error) {}
}

function parseTwitchEmotes(data) {
  data.emotes.forEach((emote) =>
    allEmotes.push({
      code: emote.code,
      url: `https://static-cdn.jtvnw.net/emoticons/v1/${emote.id}/1.0`,
    })
  )
}

function parseBTTVEmotes(data) {
  let emotes = 'sharedEmotes' in data ? data.sharedEmotes : data
  emotes.forEach((emote) => {
    allEmotes.push({
      code: emote.code,
      url: `https://cdn.betterttv.net/emote/${emote.id}/1x`,
    })
  })
}

function parse7TVEmotes(data) {
  // add 7tv emotes
  data.forEach((emote) => {
    allEmotes.push({
      code: emote.name,
      url: `https://cdn.7tv.app/emote/${emote.id}/1x`,
    })
  })
}

function escapeRegExp(str) {
  return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
}

function reducer(previous, current) {
  return previous.replace(
    new RegExp('^' + escapeRegExp(current.code) + '$', 'g'),
    '<img src="' + current.url + '">'
  )
}

function replaceEmotes(words, emotes) {
  if (!emotes) {
    return msg
  }
  const replacedWords = words.map((word) => emotes.reduce(reducer, word))
  return replacedWords.join(' ')
}
