path = require 'path'
url = require 'url'
fs = require 'fs'
app = require('connect')()
server = require('http').createServer(app)
serveStatic = require 'serve-static'
coffee = require 'coffee-script'

##
# Webserver
##
app
    .use((req, res, next) ->
        filePath = decodeURI(url.parse(req.url).pathname)
        ext = filePath.split('.').pop()

        if ext is 'coffee'
            file = path.join process.cwd(), filePath
            fs.readFile file, 'utf8', (err, data) ->
                if err
                    next()
                else
                    res.write coffee.compile data, bare: true
                    res.end()
        else
            next()
    )
    .use('/themes', serveStatic(path.join process.cwd(), 'themes'))
    .use(serveStatic(path.join process.cwd(), 'public'))
    .use((req, res) ->
        # https://stackoverflow.com/questions/19029386/node-js-http-get-request-params
        parts = url.parse(req.url, true);
        query = parts.query;

        if !query.username
            res.end('Username not given.\n')
        else
            theme = query.theme || 'dark'
            res.writeHeader(200, {"Content-Type": "text/html"});
            res.write(fs.readFileSync(path.join process.cwd(), 'themes', theme, 'index.html'))
            res.end()
    )

server.listen process.env.PORT || 1337
