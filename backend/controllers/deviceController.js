import deviceService from '../services/deviceService.js';

const newEvent = async (req, res) => {
    const result = await deviceService.logEvent(req.body.device_id, req.body.event_type);
    res.status(201).json(result);
};

export default { newEvent };