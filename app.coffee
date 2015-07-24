path = require 'path'
url = require 'url'
fs = require 'fs'
app = require('connect')()
server = require('http').createServer(app)
io = require('socket.io')(server, path: '/socket.io')
serveStatic = require 'serve-static'
twitchIrc = require 'twitch-irc'
coffee = require 'coffee-script'
config = require './config/config'

##
# Twitch
##
client = new twitchIrc.client
    channels: ['#' + config.username.toLowerCase()]
    connection:
        reconnect: true
        retries: 3

client.connect()

client.addListener 'chat', (channel, user, message) ->
    if config.notify.chat then io.emit 'message', {user: user, message: message}

client.addListener 'subscription', (channel, user) ->
    if config.notify.subscription then io.emit 'subscription', {user: user} 

client.addListener 'subanniversary', (channel, user, months) ->
    if config.notify.subanniversary then io.emit 'subanniversary', {user: user, months: months}


##
# Webserver
##
themePath = path.join process.cwd(), 'themes', config.theme
app
    .use((req, res, next) ->
        filePath = decodeURI(url.parse(req.url).pathname)
        ext = filePath.split('.').pop()

        if ext is 'coffee'
            file = path.join themePath, filePath
            fs.readFile file, 'utf8', (err, data) ->
                res.write coffee.compile data
                res.end()
        else
            next()
    )
    .use(serveStatic(path.join process.cwd(), 'themes', config.theme))
    .use(serveStatic(path.join process.cwd(), 'config'))
    .use(serveStatic(path.join process.cwd(), 'public'))

server.listen config.port || 1337
