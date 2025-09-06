import express from "express";

import dotenv from "dotenv";
dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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