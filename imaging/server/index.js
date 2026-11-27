'use strict';
const http = require('node:http');
const path = require('node:path');
const fs = require('node:fs');
const { openDb, seed, DEMO_PASSWORD, DEMO_USERS } = require('./db');
const { createApp } = require('./app');

const root = path.join(__dirname, '..');
const dataDir = process.env.DATA_DIR || path.join(root, 'data');
const dbFile = path.join(dataDir, 'imaging.db');

if (process.argv.includes('--reset')) {
  fs.rmSync(dataDir, { recursive: true, force: true });
  console.log('Removed', dataDir);
}

const db = openDb(dbFile);
if (seed(db)) {
  console.log('Seeded demo data. Demo accounts (password "%s"):', DEMO_PASSWORD);
  for (const u of DEMO_USERS) console.log(`  ${u.role.padEnd(10)} ${u.email}`);
}

const app = createApp({
  db, uploadDir: path.join(dataDir, 'uploads'), publicDir: path.join(root, 'public'),
  secureCookies: process.env.COOKIE_SECURE === '1',
});
const port = Number(process.env.PORT) || 3000;
http.createServer(app).listen(port, () => console.log(`Imaging slots app running at http://localhost:${port}`));
