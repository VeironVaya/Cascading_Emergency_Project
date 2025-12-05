import admin from "../firebase.js";

export async function sendFCM(tokens, title, body, data = {}) {
  const message = {
    notification: { title, body },
    data,
  };

  // if single token → use send()
  if (typeof tokens === "string") {
    return await admin.messaging().send({
      token: tokens,
      ...message
    });
  }

  // if multiple tokens → use sendEachForMulticast()
  if (Array.isArray(tokens)) {
    return await admin.messaging().sendEachForMulticast({
      tokens,
      notification: message.notification,
      data: message.data
    });
  }

  throw new Error("Invalid tokens");
}