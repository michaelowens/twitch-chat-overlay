const path = require('path')
const fs = require('fs/promises')
const fastify = require('fastify')()
const serveStatic = require('serve-static')

async function routes() {
  await fastify.register(require('middie'))

  fastify
    .use('/themes', serveStatic(path.join(process.cwd(), 'themes')))
    .use(serveStatic(path.join(process.cwd(), 'public')))
    .get('/chat', async (req, res) => {
      if (!req.query.username) {
        return res.send('Username not given.\n')
      } else {
        const theme = req.query.theme || 'dark'
        res.header('Content-Type', 'text/html')
        res.send(
          await fs.readFile(
            path.join(process.cwd(), 'themes', theme, 'index.html')
          )
        )
      }
    })
}

async function start() {
  try {
    await routes()
    await fastify.listen(process.env.PORT || 1337)
    const address = fastify.server.address()
    const port = typeof address === 'string' ? address : address?.port
    console.log(`Listening on http://${address.address}:${port}`)
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
}
start()
