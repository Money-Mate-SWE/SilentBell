//add here: reuse the same database connection pool
import { query } from "../db.js";


const verifyDevice = async (req, res, next) => {

    const token = req.headers['authorization']?.split(' ')[1]; //device secret
    const deviceId = req.headers['x-device-id'];

    if (!token || !deviceId) {
        return res.status(401).json({ message: 'Unauthorized: Missing token or device ID' });
    }

    try {
        const result = await query('SELECT * FROM devices WHERE device_id = $1 AND device_key = $2', [deviceId, token]);

        if (result.rows.length === 0) {
            return res.status(401).json({ message: 'Unauthorized: Invalid device' });
        }

        req.device = result.rows[0]; // Attach device info to request object
        next(); // Proceed to the next middleware or route handler
    }
    catch (error) {
        console.error('Database error:', error);
        return res.status(500).json({ error: 'Database error' });
    }
};

export default { verifyDevice };