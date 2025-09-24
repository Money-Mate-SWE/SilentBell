import express from "express";
import userController from "../controllers/userController.js";
import { jwtCheck, authorizeUser } from "../middleware/authVerification.js";

const router = express.Router();

// Route to create a new user
router.post("/", jwtCheck, userController.registerUser);

// Route to get user details by ID
router.get("/:id", jwtCheck, authorizeUser, userController.getUser);

// Route to get user preferences by ID
router.get("/:id/preferences", jwtCheck, authorizeUser, userController.getUserPreferences);

// Route to update user details by ID
router.put("/:id", jwtCheck, authorizeUser, userController.updateUser);

// Route to update user preferences by ID
router.patch("/:id/preferences", jwtCheck, authorizeUser, userController.updatePreferences);

// Route to delete a user by ID
router.delete("/:id", jwtCheck, authorizeUser, userController.deleteUser);

export default router;