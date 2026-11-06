import test from 'node:test'
import assert from 'node:assert/strict'
import { createServer } from '../src/server.js'

async function withServer(run) {
  const server = createServer('R20261106.01')
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve))
  const { port } = server.address()
  try {
    await run(`http://127.0.0.1:${port}`)
  } finally {
    await new Promise((resolve) => server.close(resolve))
  }
}

test('GET /health returns ok', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/health`)
    assert.equal(response.status, 200)
    assert.deepEqual(await response.json(), { status: 'ok' })
  })
})

test('GET /version returns the supplied version', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/version`)
    assert.equal(response.status, 200)
    assert.deepEqual(await response.json(), { version: 'R20261106.01' })
  })
})

test('unknown route returns 404', async () => {
  await withServer(async (base) => {
    const response = await fetch(`${base}/nope`)
    assert.equal(response.status, 404)
  })
})
