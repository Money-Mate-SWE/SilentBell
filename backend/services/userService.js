import { query } from "../db.js";

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
    const fields = [];
    const values = [];
    let index = 1;

    for (const [key, value] of Object.entries(preferences)) {
        fields.push(`${key} = $${index}`);
        values.push(value);
        index++;
    }

    if (fields.length === 0) {
        return null; // nothing to update
    }

    const query = `
    UPDATE preferences
    SET ${fields.join(", ")}
    WHERE user_id = $${index}
    RETURNING *;
  `;

    values.push(userId);

    const result = await db.query(query, values);
    return result.rows[0];
}

async function deleteUser(auth0Id) {
    await query(
        "DELETE FROM users WHERE auth0_id = $1",
        [auth0Id]
    );
}

export default { getOrCreateUser, getUserById, updateUser, deleteUser, getUserPreferences, updatePreferences };

