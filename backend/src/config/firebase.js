const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

/**
 * Initialize Firebase Admin SDK with service account credentials or Emulator.
 * Returns the Firestore database instance.
 */
function initializeFirebase() {
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID || "lingobreeze-vocab",
    });
    console.log("✅ Firebase Admin initialized with Firestore Emulator");
    return admin.firestore();
  }

  const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_KEY || "./serviceAccountKey.json";

  const resolvedPath = path.resolve(serviceAccountPath);
  if (!fs.existsSync(resolvedPath)) {
    console.error(`❌ Service account key not found at ${resolvedPath}`);
    console.log("💡 Tip: Set FIRESTORE_EMULATOR_HOST to run locally without a key.");
    process.exit(1);
  }

  const serviceAccount = require(resolvedPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  const db = admin.firestore();

  console.log("✅ Firebase Admin initialized successfully");

  return db;
}

module.exports = { initializeFirebase };
