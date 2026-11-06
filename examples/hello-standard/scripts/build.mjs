import { readFile, writeFile, mkdir } from 'node:fs/promises'
import { execFileSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const version = (await readFile(join(root, 'VERSION'), 'utf8')).trim()

if (!/^R\d{8}\.\d{2,3}$/.test(version)) {
  console.error(`Invalid VERSION: "${version}" (expected RYYYYMMDD.NN)`)
  process.exit(1)
}

let gitSha = 'unknown'
try {
  gitSha = execFileSync('git', ['rev-parse', '--short', 'HEAD'], {
    cwd: root,
    encoding: 'utf8',
  }).trim()
} catch {
  // Not a Git checkout (e.g. a downloaded zip); keep "unknown".
}

const manifest = {
  version,
  git_sha: gitSha,
  built_at: new Date().toISOString(),
}

await mkdir(join(root, 'dist'), { recursive: true })
await writeFile(
  join(root, 'dist', 'version.json'),
  `${JSON.stringify(manifest, null, 2)}\n`,
)

console.log(`built dist/version.json for ${version} (git ${gitSha})`)
