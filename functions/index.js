const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Callable Cloud Function: deleteAuthUser
 * Called by the admin app to permanently delete a Firebase Auth account by UID.
 * Only callable by authenticated users with role == "admin" (verified via Firestore).
 */
exports.deleteAuthUser = onCall(async (request) => {
  // 1. Must be authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const callerUid = request.auth.uid;

  // 2. Verify caller is an admin in Firestore
  const callerDoc = await admin.firestore().collection("users").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.data().role !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can delete accounts.");
  }

  const { uid } = request.data;
  if (!uid || typeof uid !== "string") {
    throw new HttpsError("invalid-argument", "A valid uid is required.");
  }

  // 3. Delete the Firebase Auth account
  try {
    await admin.auth().deleteUser(uid);
    return { success: true, message: `Auth account ${uid} deleted.` };
  } catch (err) {
    if (err.code === "auth/user-not-found") {
      // Already deleted — treat as success so UI stays consistent
      return { success: true, message: "Auth account was already deleted." };
    }
    throw new HttpsError("internal", err.message);
  }
});
