import express from "express";
import { query } from "./db.js";   

import dotenv from "dotenv";
dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- Route to test DB connection ---
app.get('/db-check', async (req, res) => {
  try {
    const result = await query('SELECT NOW()');
    res.json({ success: true, time: result.rows[0].now });
  } catch (err) {
    console.error("Database connection error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Define a basic route
app.get('/', (req, res) => {
    res.send('Hello from Express!');
});

const PORT = process.env.PORT || 4000;

// Start the server
app.listen(PORT, () => {
    console.log(` Server running on http://localhost:${PORT}`);
}).on('error', (err) => {
    console.error(" Server failed to start:", err);
});