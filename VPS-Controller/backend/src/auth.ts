import { createHmac, randomBytes, scryptSync, timingSafeEqual } from 'node:crypto';

const PASSWORD_PREFIX = 'scrypt';
const SCRYPT_N = 16384;
const SCRYPT_R = 8;
const SCRYPT_P = 1;
const KEY_LENGTH = 64;

function base64Url(value: string | Buffer): string {
  return Buffer.from(value).toString('base64url');
}

function sign(input: string, secret: string): string {
  return createHmac('sha256', secret).update(input).digest('base64url');
}

export function hashPassword(password: string): string {
  if (!password || password.length > 1024) throw new Error('invalid_password');
  const salt = randomBytes(16);
  const derived = scryptSync(password, salt, KEY_LENGTH, {
    N: SCRYPT_N,
    r: SCRYPT_R,
    p: SCRYPT_P,
    maxmem: 64 * 1024 * 1024,
  });
  return `${PASSWORD_PREFIX}$${SCRYPT_N}$${SCRYPT_R}$${SCRYPT_P}$${salt.toString('base64url')}$${derived.toString('base64url')}`;
}

export function verifyPassword(password: string, encoded: string): boolean {
  try {
    const [prefix, nText, rText, pText, saltText, digestText] = encoded.split('$');
    if (prefix !== PASSWORD_PREFIX || !nText || !rText || !pText || !saltText || !digestText) return false;
    const n = Number(nText);
    const r = Number(rText);
    const p = Number(pText);
    if (!Number.isSafeInteger(n) || !Number.isSafeInteger(r) || !Number.isSafeInteger(p) || n < 1024 || r < 1 || p < 1 || n > 1_048_576) return false;
    const expected = Buffer.from(digestText, 'base64url');
    const actual = scryptSync(password, Buffer.from(saltText, 'base64url'), expected.length, {
      N: n,
      r,
      p,
      maxmem: 64 * 1024 * 1024,
    });
    return expected.length === actual.length && timingSafeEqual(expected, actual);
  } catch {
    return false;
  }
}

export function createSessionToken(username: string, secret: string, ttlSeconds: number): string {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const payload = base64Url(JSON.stringify({ sub: username, iat: now, exp: now + ttlSeconds, jti: randomBytes(12).toString('hex') }));
  const unsigned = `${header}.${payload}`;
  return `${unsigned}.${sign(unsigned, secret)}`;
}

export function verifySessionToken(token: string, secret: string): boolean {
  try {
    const [headerText, payloadText, signature] = token.split('.');
    if (!headerText || !payloadText || !signature || !secret) return false;
    const header = JSON.parse(Buffer.from(headerText, 'base64url').toString('utf8')) as { alg?: string; typ?: string };
    if (header.alg !== 'HS256' || header.typ !== 'JWT') return false;
    const expected = Buffer.from(sign(`${headerText}.${payloadText}`, secret));
    const received = Buffer.from(signature);
    if (expected.length !== received.length || !timingSafeEqual(expected, received)) return false;
    const payload = JSON.parse(Buffer.from(payloadText, 'base64url').toString('utf8')) as { exp?: unknown; sub?: unknown };
    return typeof payload.sub === 'string' && typeof payload.exp === 'number' && payload.exp > Math.floor(Date.now() / 1000);
  } catch {
    return false;
  }
}
