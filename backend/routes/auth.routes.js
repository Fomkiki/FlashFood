import express from "express";
import {  loginUser,registerUser,getMe , logoutUser, updateUser, getAllUsersAdmin } from "../controllers/auth.controller.js";
import { authToken } from "../middleware/auth.middleware.js";
import { authRole } from '../middleware/authRole.middleware.js';
const router = express.Router();

router.post("/login", loginUser);
router.post("/register", registerUser);
router.get("/me", authToken, getMe);
router.post("/logout", logoutUser);
router.put("/update", authToken, updateUser);
router.get('/admin/users', authToken, authRole('admin'), getAllUsersAdmin);

export default router;