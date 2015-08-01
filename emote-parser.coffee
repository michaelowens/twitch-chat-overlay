https = require 'https'

allEmotes = {}

exports.parse = (msg) -> replaceEmotes msg

exports.load = (config) ->
    if config.emotes
        fetchEmotes 'https://twitchemotes.com/global.json', parseTwitchEmotes

    if config.subemotes
        fetchEmotes 'https://twitchemotes.com/subscriber.json', parseTwitchSubEmotes

    if config.bttvemotes
        fetchEmotes 'https://api.betterttv.net/2/emotes', parseBTTVEmotes
        fetchEmotes 'https://api.betterttv.net/2/channels/' + config.username, parseBTTVEmotes

fetchEmotes = (url, callback) ->
    https.get url, (response) ->
        body = ''

        response.on 'data', (data) ->
            body += data

        response.on 'end', ->
            # great error handling
            callback JSON.parse body

parseTwitchEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) -> allEmotes[k] = emotes[k].url

parseTwitchSubEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) ->
        Object.keys(emotes[k].emotes).forEach (k2) ->
            allEmotes[k2] = emotes[k].emotes[k2]

parseBTTVEmotes = (data) ->
    data.emotes.forEach (emote) ->
        allEmotes[emote.code] = parseBTTVURL data.urlTemplate, emote

parseBTTVURL = (tpl, emote) ->
    tpl
        .replace /{{id}}/, emote.id
        .replace /{{image}}/, '1x'

# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
escapeRegExp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

urlToImage = (url) -> '<img src="' + url + '">'

replaceEmotes = (msg) ->
    return msg if not allEmotes

    for emote of allEmotes
        msg = msg.replace new RegExp('(?!\S)' + escapeRegExp(emote) + '(?!\S)', 'g'), urlToImage(allEmotes[emote])

    return msg # I don't want this
