import deviceService from '../services/deviceService.js';
import userService from '../services/userService.js';
import { sendPushNotification } from '../middleware/apn.js';
import { ApiGatewayManagementApiClient, PostToConnectionCommand } from "@aws-sdk/client-apigatewaymanagementapi";


const newEvent = async (req, res) => {
    const result = await deviceService.logEvent(req.body.device_token, req.body.event_type);

    const deviceTokens = await userService.getDeviceTokensForUser(req.body.device_token)

    await Promise.all(deviceTokens.map(token =>
        sendPushNotification(token, "SilentBell Alert", `${req.body.event_type} detected from your device`)
    ));

    const connectionIds = await userService.getConnectionIds(req.body.device_token)

    if (connectionIds.length > 0) {
        const client = new ApiGatewayManagementApiClient({
            endpoint: "https://nfdvsaxbu9.execute-api.us-east-1.amazonaws.com/prod/",
        });

        // Send WebSocket command to all active bulbs
        const message = JSON.stringify({ cmd: "flash_multicolor" });

        for (const ws_connection_id of connectionIds) {
            try {
                await client.send(
                    new PostToConnectionCommand({
                        ConnectionId: ws_connection_id,
                        Data: message,
                    })
                );
            } catch (err) {
                console.warn(`⚠️ Failed to send to ${row.ws_connection_id}:`, err.message);
            }
        }
    }
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

const getLights = async (req, res) => {
    const devices = await deviceService.getLightsByUserId(req.params.id);
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

const registerLight = async (req, res) => {
    try {
        const token = await deviceService.registerNewLight(req.params.id, req.body.device_name, req.body.mac);
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

export default { newEvent, getEvents, getAllEvents, getDevices, getLights, registerDevice, registerLight, updateDevice, deleteDevice };