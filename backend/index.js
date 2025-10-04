import dotenv from "dotenv";
dotenv.config();

import express from "express";
import dbRoute from "./routes/dbRoute.js";
import deviceRoute from "./routes/deviceRoute.js";
import userRoute from "./routes/userRoute.js";

import ServerlessHttp from "serverless-http";

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- Route to test DB connection ---
app.use('/db', dbRoute);
app.use('/device', deviceRoute);
app.use('/user', userRoute);

// Define a basic route
app.get('/', (req, res) => {
  res.send('Hello from Express!');
});

const PORT = process.env.PORT || 4000;

// Start the server
// app.listen(PORT, () => {
//   console.log(` Server running on http://localhost:${PORT}`);
// }).on('error', (err) => {
//   console.error(" Server failed to start:", err);
// });
export const handler = ServerlessHttp(app);