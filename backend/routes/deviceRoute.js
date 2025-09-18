import express from 'express';
import deviceController from '../controllers/deviceController.js';
import { verifyDevice } from '../middleware/deviceVerification.js';

const router = express.Router();

// Route to test DB connection
router.post('/logEvent', verifyDevice, deviceController.newEvent);


export default router;