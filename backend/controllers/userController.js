import userService from "../services/userService.js";

const registerUserDevice = async (req, res) => {
    try {
        const userDevice = await userService.registerUserDevice(req.params.id, req.body.token);
        res.status(201);
    } catch (error) {
        console.error("Error registering user device:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }

}

const registerUser = async (req, res) => {
    try {
        const { name, email } = req.body;
        const sub = req.auth.payload.sub; // Extract sub from authenticated request
        if (!name) {
            return res.status(400).json({ error: "Missing required fields: name" });
        }
        if (!email) {
            return res.status(400).json({ error: "Missing required fields: email" });
        }
        if (!sub) {
            return res.status(400).json({ error: "Missing required fields: sub" });
        }
        const user = await userService.getOrCreateUser({ name, email, sub });
        res.status(201).json(user);
    } catch (error) {
        console.error("Error registering/checking user:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const updateUser = async (req, res) => {
    try {
        const user = await userService.updateUser(req.params.id, req.body);
        res.status(200).json(user);
    } catch (error) {
        console.error("Error updating user:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const getUser = async (req, res) => {
    try {
        const user = await userService.getUserById(req.params.id);
        if (user) {
            res.status(200).json(user);
        } else {
            res.status(404).json({ error: "User not found" });
        }
    } catch (error) {
        console.error("Error fetching user:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const getUserPreferences = async (req, res) => {
    try {
        const preferences = await userService.getUserPreferences(req.params.id);
        if (preferences) {
            res.status(200).json(preferences);
        } else {
            res.status(404).json({ error: "Preferences not found" });
        }
    } catch (error) {
        console.error("Error fetching preferences:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const updatePreferences = async (req, res) => {
    try {
        const updatedPreferences = await userService.updatePreferences(req.params.id, req.body);
        if (updatedPreferences) {
            res.status(200).json(updatedPreferences);
        } else {
            res.status(400).json({ error: "No preferences to update" });
        }
    } catch (error) {
        console.error("Error updating preferences:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

const deleteUser = async (req, res) => {
    try {
        await userService.deleteUser(req.params.id);
        res.status(204).send();
    } catch (error) {
        console.error("Error deleting user:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

export default { registerUserDevice, registerUser, updateUser, getUser, deleteUser, getUserPreferences, updatePreferences };
