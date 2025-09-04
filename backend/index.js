const express = require('express');
const app = express();
const PORT = 3000;

// Define a basic route
app.get('/', (req, res) => {
    res.send('Hello from Express!');
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});