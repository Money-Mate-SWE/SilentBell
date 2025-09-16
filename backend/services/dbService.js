import { query } from "../db.js";

class dbService {
    async checkConnection() {
        try {
            const result = await query('SELECT NOW()');
            return { success: true, time: result.rows[0].now };
        } catch (err) {
            console.error("Database connection error:", err);
            return { success: false, error: err.message };
        }
    }
}

export default new dbService();
