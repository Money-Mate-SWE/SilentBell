import express from 'express';
import deviceController from '../controllers/deviceController.js';
import { verifyDevice } from '../middleware/deviceVerification.js';
import { getJwtCheck, authorizeUser } from '../middleware/authVerification.js';

const router = express.Router();

const jwtCheck = getJwtCheck();

router.post('/logEvent', verifyDevice, deviceController.newEvent);

router.get('/events/:id', jwtCheck, /*authorizeUser,*/ deviceController.getEvents);

router.get('/devices/:id', jwtCheck, /*authorizeUser,*/ deviceController.getDevices);

router.post('/:id', jwtCheck, /*authorizeUser,*/ deviceController.registerDevice);

router.put('/update', verifyDevice, /*authorizeUser,*/ deviceController.updateDevice);

router.delete('/delete/:id', jwtCheck, /*authorizeUser,*/ deviceController.deleteDevice);

export default router;