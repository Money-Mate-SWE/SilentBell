import apn from "apn";


const options = {
  token: {
    key: Buffer.from(process.env.KEY, "utf-8"), // your .p8 file path
    keyId: process.env.KEY_ID,            // Key ID
    teamId: process.env.TEAM_ID            // Team ID
  },
  production: false // set true when you release to App Store
};

const apnProvider = new apn.Provider(options);

export async function sendPushNotification(deviceToken, title, message) {
  const note = new apn.Notification();
  note.alert = { title, body: message };
  note.sound = "default";
  note.topic = "com.seniordesign.SilentBellApps"; // your bundle ID

  try {
    const result = await apnProvider.send(note, deviceToken);
    console.log("📨 Push sent:", result.sent.length);
    console.log("❌ Failed:", result.failed.length);
    result.failed.forEach(f => {
      console.error("Push failed for token:", f.device, "reason:", f.response?.reason);
    });
  } catch (error) {
    console.error("Push error:", error);
  }
}
