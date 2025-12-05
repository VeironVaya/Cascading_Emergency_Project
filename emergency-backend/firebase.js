import admin from "firebase-admin";
import dotenv from "dotenv";
import fs from "fs";

dotenv.config();

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(
    fs.readFileSync("./serviceAccountKey.json", "utf8")
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
  });

  console.log("🔥 Firebase Admin initialized");
}

export default admin;
