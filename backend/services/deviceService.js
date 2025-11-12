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
        "INSERT INTO devices (device_key, device_name, user_id, last_seen) VALUES ($1, $2, $3, now())",
        [token, device_name, user_id]
    );

    return token; // return token so you can flash it to the ESP32
}

async function registerNewLight(user_id, device_name, mac) {
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
        "INSERT INTO devices (device_key, device_name, user_id, last_seen, mac) VALUES ($1, $2, $3, now())",
        [token, device_name, user_id, mac]
    );

    return token; // return token so you can flash it to the ESP32
}

async function logEvent(device_token, event_type) {

    const result = await query(
        "SELECT device_id FROM devices WHERE device_key=$1",
        [device_token]
    );

    if (result.rows.length === 0) {
        throw new Error("Device not found");
    };

    const device_id = result.rows[0].device_id;
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
        "SELECT device_id, user_id, device_name,status, last_seen, created_at, device_key FROM devices WHERE user_id = $1 AND mac is NULL",
        [user_id]
    );
    return res.rows;
}

async function getLightsByUserId(user_id) {
    const res = await query(
        "SELECT device_id, user_id, device_name,status, last_seen, created_at, device_key FROM devices WHERE user_id = $1 AND mac IS NOT NULL",
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

async function updateDeviceStatus(device_key, status) {
    const res = await query(
        "UPDATE devices SET status = $1, last_seen = now() WHERE device_key = $2 RETURNING *",
        [status, device_key]
    );
    return res.rows[0];
}

async function deleteDevice(device_id) {
    await query(
        "DELETE FROM devices WHERE id = $1",
        [device_id]
    );
}

export default { registerNewDevice, registerNewLight, logEvent, getDeviceByUserId, getLightsByUserId, getEventsByUserId, getEventsByDeviceId, updateDeviceStatus, deleteDevice };