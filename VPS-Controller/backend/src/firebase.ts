import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getMessaging } from 'firebase-admin/messaging';
import { env } from './config.js';

let app: App | null = null;

export function firebaseApp(): App | null {
  if (app) return app;
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    return null;
  }
  if (getApps().length) {
    app = getApps()[0] ?? null;
    return app;
  }
  app = initializeApp({
    credential: cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
    })
  });
  return app;
}

export async function verifyUserToken(token: string): Promise<{ uid: string } | null> {
  const fapp = firebaseApp();
  if (!fapp) return null;
  const decoded = await getAuth(fapp).verifyIdToken(token);
  return { uid: decoded.uid };
}

export async function sendPush(tokens: string[], title: string, body: string): Promise<void> {
  const fapp = firebaseApp();
  if (!fapp || tokens.length === 0) return;
  await getMessaging(fapp).sendEachForMulticast({
    tokens,
    notification: { title, body }
  });
}
