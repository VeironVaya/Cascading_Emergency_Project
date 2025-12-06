import admin from "../firebase.js";
import { sendFCM } from "./fcmService.js";

export async function cascadeToNext(emergencyId, emergency) {
  const db = admin.database().ref("emergencies/" + emergencyId);

  let index = emergency.currentPriorityIndex;
  const list = emergency.priorities;

  if (index >= list.length) {
    console.log("🔥 No more priorities left.");
    await db.update({ status: "all_failed" });
    return;
  }

  const helper = list[index];
  const token = helper.fcmToken;

  if (!token) {
    console.log(`❌ Priority ${index} has NO token → skipping`);
    emergency.currentPriorityIndex++;
    await db.update({ currentPriorityIndex: emergency.currentPriorityIndex });
    return cascadeToNext(emergencyId, emergency);
  }

  console.log(`📨 Sending notification to priority ${index}:`, token);

  await sendFCM(
    token,
    `Emergency: ${emergency.type}`,
    `${emergency.need} — ${emergency.condition || ""}`,
    { emergencyId }
  );

  const sentTime = Date.now();
  await db.update({ lastSentAt: sentTime });

  setTimeout(async () => {
    const snapshot = await db.get();
    const updated = snapshot.val();

    if (!updated) return;
    if (updated.helperAccepted) return;
    if (updated.status !== "pending") return;

    updated.currentPriorityIndex++;

    await db.update({
      currentPriorityIndex: updated.currentPriorityIndex,
    });

    console.log("⏭ Moving to next priority:", updated.currentPriorityIndex);

    cascadeToNext(emergencyId, updated);

  }, 10000);
}
