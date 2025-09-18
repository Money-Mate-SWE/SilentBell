//add here: reuse the same database connection pool
import { query } from "./db.js";

import crypto from "crypto";

// Generate a random 64-character token
function generateDeviceToken() {
    return crypto.randomBytes(32).toString("hex");
}

// Generate token and insert a new device in DB
async function registerNewDevice(device_name) {
    let token;
    let exists = true;

    while (exists) {
        token = generateDeviceToken();
        const res = await query(
            "SELECT 1 FROM devices WHERE device_key=$1",
            [token]
        );
        exists = res.rows.length > 0;
    }

    await query(
        "INSERT INTO devices (device_key, device_name) VALUES ($1, $2)",
        [token, device_name]
    );

    return token; // return token so you can flash it to the ESP32
}

async function logEvent(device_id, event_type) {
    try {
        const res = await query(
            "INSERT INTO events (device_id, event_type, event_time) VALUES ($1, $2, NOW()) RETURNING *",
            [device_id, event_type]
        );
        return res.rows[0];
    } catch (error) {
        console.error('Error logging event:', error);
        throw error;
    }
}

export { registerNewDevice, logEvent };