import { query } from "../db.js";

async function registerUserDevice(id, token) {
    const result = await query(
        "INSERT INTO device_tokens (user_id, token) VALUES ($1, $2) RETURNING *",
        [id, token]
    );

    return result;
}

async function getDeviceTokensForUser(token) {
    const r = await query(
        "SELECT user_id FROM devices WHERE device_key = $1",
        [token]
    );

    if (!r.rows[0]) {
        throw new Error("Device not found");
    }

    const id = r.rows[0].user_id;

    const result = await query(
        "SELECT token FROM device_tokens WHERE user_id = $1",
        [id]
    );

    return result.rows.map(row => row.token);
    ;
}

async function getOrCreateUser({ name, email, sub }) {
    // Check if user already exists
    const existingUser = await query(
        "SELECT user_id, name, email, created_at, last_login, last_name FROM users WHERE sub = $1",
        [sub]
    );

    if (existingUser.rows.length > 0) {
        return existingUser.rows[0];
    }

    // If not, create a new user
    const res = await query(
        "INSERT INTO users (sub, email, name) VALUES ($1, $2, $3) RETURNING user_id, name, email, created_at, last_login, last_name",
        [sub, email, name]
    );

    const user = res.rows[0];

    await query("INSERT INTO preferences (user_id, enable_vibration, enable_light, enable_push) VALUES ($1, $2, $3)",
        [user.user_id, true, true, true]
    );

    return user;
}

async function getUserById(userId) {
    const res = await query(
        "SELECT user_id, name, email, created_at, last_login, last_name FROM users WHERE id = $1",
        [userId]
    );

    return res.rows[0];
}

async function getUserPreferences(userId) {
    const res = await query(
        "SELECT * FROM preferences WHERE user_id = $1",
        [userId]
    );

    return res.rows[0];
}

async function updateUser(auth0Id, userData) {
    const { name } = userData;

    const res = await query(
        "UPDATE users SET name = $1 WHERE auth0_id = $2 RETURNING *",
        [name, auth0Id]
    );

    return res.rows[0];
}

export async function updatePreferences(userId, preferences) {
    const { enable_vibration, enable_light, enable_push, priority_mode } = preferences;

    const result = await query("UPDATE preferences SET enable_vibration = $1, enable_light = $2, enable_push = $3, priority_mode = $4 WHERE user_id = $5 RETURNING *", [enable_vibration, enable_light, enable_push, priority_mode, userId]);

    return result.rows[0];
}

async function deleteUser(auth0Id) {
    await query(
        "DELETE FROM users WHERE auth0_id = $1",
        [auth0Id]
    );
}

export default { registerUserDevice, getDeviceTokensForUser, getOrCreateUser, getUserById, updateUser, deleteUser, getUserPreferences, updatePreferences };

