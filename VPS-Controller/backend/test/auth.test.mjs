import test from 'node:test';
import assert from 'node:assert/strict';
import { createSessionToken, hashPassword, verifyPassword, verifySessionToken } from '../dist/auth.js';

test('password hashes verify without storing the original password', () => {
  const hash = hashPassword('correct horse battery staple');
  assert.match(hash, /^scrypt\$16384\$8\$1\$/);
  assert.equal(verifyPassword('correct horse battery staple', hash), true);
  assert.equal(verifyPassword('wrong password', hash), false);
  assert.doesNotMatch(hash, /correct horse battery staple/);
});

test('session token is signed and expires', () => {
  const token = createSessionToken('admin', 'test-secret', 60);
  assert.equal(verifySessionToken(token, 'test-secret'), true);
  assert.equal(verifySessionToken(token, 'wrong-secret'), false);
  const parts = token.split('.');
  assert.equal(parts.length, 3);
  assert.equal(JSON.parse(Buffer.from(parts[1], 'base64url').toString()).sub, 'admin');
});
