//add here: reuse the same database connection pool
import { query } from "../db.js";

import crypto from "crypto";

// Generate a random 64-character token
function generateDeviceToken() {
    return crypto.randomBytes(32).toString("hex");
}

// Generate token and insert a new device in DB
async function registerNewDevice(user_id, device_name) {
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
        "INSERT INTO devices (device_key, device_name, user_id) VALUES ($1, $2, $3)",
        [token, device_name, user_id]
    );

    return token; // return token so you can flash it to the ESP32
}

async function logEvent(device_token, event_type) {

    const device_id = await query(
        "SELECT device_id FROM devices WHERE device_key=$1",
        [device_token]
    );

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

async function getDeviceByUserId(user_id) {
    const res = await query(
        "SELECT * FROM devices WHERE user_id = $1",
        [user_id]
    );
    return res.rows;
}

async function getEventsByDeviceId(device_id) {
    const res = await query(
        "SELECT * FROM events WHERE device_id = $1 ORDER BY event_time DESC",
        [device_id]
    );
    return res.rows;
}

async function getEventsByUserId(user_id) {
    const res = await query(
        "SELECT events.event_id, devices.device_name, events.event_type, events.event_time FROM events JOIN devices ON devices.device_id = events.device_id WHERE devices.user_id = $1 ORDER BY events.event_time DESC",
        [user_id]
    );
    return res.rows;
}

async function updateDeviceName(device_id, new_name) {
    const res = await query(
        "UPDATE devices SET device_name = $1 WHERE id = $2 RETURNING *",
        [new_name, device_id]
    );
    return res.rows[0];
}

async function deleteDevice(device_id) {
    await query(
        "DELETE FROM devices WHERE id = $1",
        [device_id]
    );
}

export default { registerNewDevice, logEvent, getDeviceByUserId, getEventsByUserId, getEventsByDeviceId, updateDeviceName, deleteDevice };