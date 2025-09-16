//add here: reuse the same database connection pool
import { query } from "./db.js";

import crypto from "crypto";

// Generate a random 64-character token
function generateDeviceToken() {
    return crypto.randomBytes(32).toString("hex");
}

// Generate token and insert a new device in DB
async function registerNewDevice(location) {
    let token;
    let exists = true;

    while (exists) {
        token = generateDeviceToken();
        const res = await query(
            "SELECT 1 FROM devices WHERE device_secret=$1",
            [token]
        );
        exists = res.rows.length > 0;
    }

    await query(
        "INSERT INTO devices (device_secret, location) VALUES ($1, $2)",
        [token, location]
    );

    return token; // return token so you can flash it to the ESP32
}

module.exports = { registerNewDevice };
