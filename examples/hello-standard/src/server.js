import { createServer as createHttpServer } from 'node:http'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const here = dirname(fileURLToPath(import.meta.url))

export function readVersion() {
  return readFileSync(join(here, '..', 'VERSION'), 'utf8').trim()
}

export function createServer(version = readVersion()) {
  return createHttpServer((req, res) => {
    if (req.url === '/health') {
      res.writeHead(200, { 'content-type': 'application/json' })
      res.end(JSON.stringify({ status: 'ok' }))
      return
    }

    if (req.url === '/version') {
      res.writeHead(200, { 'content-type': 'application/json' })
      res.end(JSON.stringify({ version }))
      return
    }

    if (req.url === '/') {
      res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8' })
      res.end(`Hello from AI Dev Standard ${version}\n`)
      return
    }

    res.writeHead(404, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'not found' }))
  })
}

const isMain = process.argv[1] === fileURLToPath(import.meta.url)
if (isMain) {
  const port = Number(process.env.PORT || 3000)
  createServer().listen(port, '127.0.0.1', () => {
    console.log(`hello-standard listening on http://127.0.0.1:${port}`)
  })
}
