import deviceService from '../services/deviceService.js';

const newEvent = async (req, res) => {
    const result = await deviceService.logEvent(req.body.device_id, req.body.event_type);
    res.status(201).json(result);
};

const getEvents = async (req, res) => {
    const events = await deviceService.getEventsByDeviceId(req.body.device_id);
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
        const updatedDevice = await deviceService.updateDeviceName(req.body.device_id, req.body.device_name);
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

export default { newEvent, getEvents, getDevices, registerDevice, updateDevice, deleteDevice };