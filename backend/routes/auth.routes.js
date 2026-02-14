import express from "express";
import {  loginUser,registerUser,getMe , logoutUser } from "../controllers/auth.controller.js";
import { authToken } from "../middleware/auth.middleware.js";
const router = express.Router();

router.post("/login", loginUser);
router.post("/register", registerUser);
router.get("/me", authToken, getMe);
router.post("/logout", logoutUser);

export default router;