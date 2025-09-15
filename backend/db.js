// db.js
import { Pool } from 'pg';
import dns from 'dns/promises';
import dotenv from 'dotenv';
dotenv.config();

let connectionString = process.env.DATABASE_URL;

export const getPool = async () => {
  // Resolve host to IPv4 and replace it in the URL (optional)
  try {
    const url = new URL(connectionString);
    const { address } = (await dns.lookup(url.hostname, { family: 4 }));
    url.hostname = address; // replace host with IPv4
    connectionString = url.toString();
  } catch { /* ignore if resolution fails */ }

  return new Pool({
    connectionString,
    ssl: { require: true, rejectUnauthorized: false },
  });
};

const pool = await getPool();
export const query = (text, params) => pool.query(text, params);
