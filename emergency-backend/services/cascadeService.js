import admin from "../firebase.js";
import { sendFCM } from "./fcmService.js";

export async function cascadeToNext(emergencyId, emergency) {
  const db = admin.database().ref(`emergencies/${emergencyId}`);

  const index = emergency.currentPriorityIndex;
  const list = emergency.priorities;

  if (index >= list.length) {
    console.log("🔥 No more priorities left.");
    await db.update({ status: "all_failed" });
    
    return;
  }

  const helperUid = list[index].targetUid;

  const tokenSnap = await admin.database()
    .ref(`users/${helperUid}/fcmToken`)
    .get();

  const token = tokenSnap.val();

  if (!token) {
    console.log("❌ No token → skip helper");
    emergency.currentPriorityIndex++;
    await db.update({ currentPriorityIndex: emergency.currentPriorityIndex });
    return cascadeToNext(emergencyId, emergency);
  }

  console.log(`📨 Sending notification to priority ${index}`);

  try {
    await sendFCM(
      token,
      `Emergency: ${emergency.type}`,
      `${emergency.need} — ${emergency.condition || ""}`,
      { emergencyId }
    );
  } catch (err) {
    console.error("❌ FCM error:", err.code);

    if (err.code === "messaging/registration-token-not-registered") {
      console.log("🗑 Removing invalid token");
      await admin.database()
        .ref(`users/${helperUid}/fcmToken`)
        .remove();
    }

    emergency.currentPriorityIndex++;
    await db.update({ currentPriorityIndex: emergency.currentPriorityIndex });

    return cascadeToNext(emergencyId, emergency);
  }

  await db.update({
    lastSentAt: Date.now(),
    status: "waiting_response",
  });

  setTimeout(async () => {
    const snap = await db.get();
    const updated = snap.val();

    if (!updated) return;
    if (updated.helperAccepted) return;
    if (updated.status !== "waiting_response") return;

    updated.currentPriorityIndex++;

    await db.update({
      currentPriorityIndex: updated.currentPriorityIndex,
      status: "pending",
    });

    console.log("⏭ Moving to next priority:", updated.currentPriorityIndex);

    cascadeToNext(emergencyId, updated);
  }, 10000);
}
