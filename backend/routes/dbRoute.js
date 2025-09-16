import express from 'express';
import dbController from '../controllers/dbController.js';

const router = express.Router();

// Route to test DB connection
router.get('/db-check', dbController.checkDBConnection);


export default router;