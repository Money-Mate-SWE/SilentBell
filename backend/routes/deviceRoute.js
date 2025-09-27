import express from 'express';
import deviceController from '../controllers/deviceController.js';
import verifyDevice from '../middleware/deviceVerification.js';
import { jwtCheck, authorizeUser } from '../middleware/authVerification.js';

const router = express.Router();

router.post('/logEvent', verifyDevice, deviceController.newEvent);

router.get('/events/:id', jwtCheck, authorizeUser, deviceController.getEvents);

router.get('/devices/:id', jwtCheck, authorizeUser, deviceController.getDevices);

router.post('/:id', jwtCheck, authorizeUser, deviceController.registerDevice);

router.put('/update/:id', jwtCheck, authorizeUser, deviceController.updateDevice);

router.delete('/delete/:id', jwtCheck, authorizeUser, deviceController.deleteDevice);

export default router;