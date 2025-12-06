import admin from "../firebase.js";
import { sendFCM } from "../services/fcmService.js";
import { cascadeToNext  } from "../services/cascadeService.js";

export async function createEmergency(req, res) {
  try {
    const db = admin.database().ref();

    const {
      senderUid,
      type,
      condition,
      need,
      location,
      priorities,
    } = req.body;

    if (!type || !need || !location || !priorities || priorities.length === 0) {
      return res.status(400).json({ error: "Missing fields" });
    }

    // ---- 1) Create emergency entry ----
    const ref = db.child("emergencies").push();
    const emergencyId = ref.key;

    const emergency = {
      senderUid,
      type,
      condition,
      need,
      location,
      priorities,
      status: "pending",
      currentPriorityIndex: 0,
      helperAccepted: false,
      createdAt: Date.now(),
      lastSentAt: Date.now(),
    };

    await ref.set(emergency);

    // ---- 2) Start cascading logic ----
    cascadeToNext(emergencyId, emergency);

    return res.json({ ok: true, emergencyId });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }




}







export async function acceptEmergency(req, res) {
  const { id } = req.params;

  const db = admin.database().ref("emergencies/" + id);

  await db.update({
    status: "accepted",
    helperAccepted: true
  });

  console.log("✅ Emergency accepted by helper");

  return res.json({ ok: true });
}

export async function rejectEmergency(req, res) {
  const { id } = req.params;
  const db = admin.database().ref("emergencies/" + id);

  const snap = await db.get();
  const emergency = snap.val();

  // increment priority index
  emergency.currentPriorityIndex++;

  await db.update({
    currentPriorityIndex: emergency.currentPriorityIndex
  });

  console.log("❌ Helper rejected, moving to next...");

  // continue cascade
  cascadeToNext(id, emergency);

  return res.json({ ok: true });
}

