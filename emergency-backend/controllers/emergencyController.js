import admin from "../firebase.js";
import { sendFCM } from "../services/fcmService.js";
import { getNearestHelper } from "../services/priorityService.js";

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
      mode // "nearest" or "priority"
    } = req.body;

    if (!type || !need || !location) {
      return res.status(400).json({ error: "Missing fields" });
    }

    // Create emergency entry
    const ref = db.child("emergencies").push();
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
      lastSentAt: Date.now()
    };

    await ref.set(emergency);
    const id = ref.key;

    // --- Send notification ---
    let targetHelper = null;

    if (mode === "nearest") {
      targetHelper = getNearestHelper(location, priorities);
    } else {
      targetHelper = priorities[0];
    }

    if (!targetHelper.fcmToken) {
      return res.json({ ok: true, message: "No helper has FCM token!" });
    }

    await sendFCM(
      targetHelper.fcmToken,
      `Emergency: ${type}`,
      `${need} — ${condition || ""}`,
      { emergencyId: id }
    );

    return res.json({ ok: true, emergencyId: id });

  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
