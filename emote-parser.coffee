https = require 'https'

allEmotes = []

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
    Object.keys(emotes).forEach (k) -> allEmotes.push code: k, url: emotes[k].url

parseTwitchSubEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) ->
        Object.keys(emotes[k].emotes).forEach (k2) ->
            allEmotes.push code: k2, url: emotes[k].emotes[k2]

parseBTTVEmotes = (data) ->
    data.emotes.forEach (emote) ->
        allEmotes.push code: emote.code, url: parseBTTVURL(data.urlTemplate, emote) 

parseBTTVURL = (tpl, emote) ->
    tpl
        .replace /{{id}}/, emote.id
        .replace /{{image}}/, '1x'

# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
escapeRegExp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

urlToImage = (url) -> '<img src="' + url + '">'

reducer = (previous, current) ->
    previous.replace new RegExp('\\b' + escapeRegExp(current.code) + '\\b', 'g'), urlToImage(current.url)

replaceEmotes = (msg) ->
    return msg if not allEmotes
    allEmotes.reduce reducer, msg