import deviceService from '../services/deviceService.js';
import userService from '../services/userService.js';
import { sendPushNotification } from '../middleware/apn.js';

const newEvent = async (req, res) => {
    const result = await deviceService.logEvent(req.body.device_token, req.body.event_type);

    const deviceTokens = await userService.getDeviceTokensForUser(req.body.device_token)
    await Promise.all(deviceTokens.map(token =>
        sendPushNotification(token, "SilentBell Alert", `${req.body.event_type} detected from your device`)
    ));

    res.status(201).json(result);
};

const getEvents = async (req, res) => {
    const events = await deviceService.getEventsByDeviceId(req.params.id);
    res.status(200).json(events);
};

const getAllEvents = async (req, res) => {
    const events = await deviceService.getEventsByUserId(req.params.id);
    res.status(200).json(events);
};

const getDevices = async (req, res) => {
    const devices = await deviceService.getDeviceByUserId(req.params.id);
    res.status(200).json(devices);
};

const registerDevice = async (req, res) => {
    try {
        const token = await deviceService.registerNewDevice(req.params.id, req.body.device_name);
        res.status(201).json({ device_key: token });
    } catch (error) {
        console.error("Error registering device:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const updateDevice = async (req, res) => {
    try {
        const updatedDevice = await deviceService.updateDeviceStatus(req.body.device_key, req.body.status);
        res.status(200).json(updatedDevice);
    } catch (error) {
        console.error("Error updating device:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const deleteDevice = async (req, res) => {
    try {
        await deviceService.deleteDevice(req.body.device_id);
        res.status(204).send();
    } catch (error) {
        console.error("Error deleting device:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

export default { newEvent, getEvents, getAllEvents, getDevices, registerDevice, updateDevice, deleteDevice };