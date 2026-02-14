import * as userModel from "../models/user.model.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";


export const loginUser = async (req, res) => {
  try{
    const { email, password } = req.body;
    if(!email || !password){
      return  res.status(400).json({ message: "All fields are required" });
    }
    const user = await userModel.getUserByEmail(email);
    if(user.length === 0){
      return res.status(401).json({ message: "Invalid Email" });
    }
    const validPass = await bcrypt.compare(password, user[0].password);
    if(!validPass){
      return res.status(401).json({ message: "Invalid Password" });
    }
    const token = jwt.sign({ id: user[0].id, role: user[0].role }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.cookie('token', token, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: "strict", maxAge: 60 * 60 * 1000 });
    res.status(200).json({  message: "Login successful" });
  }
  catch(err){
    console.error("Login error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const registerUser = async (req, res) => {
  try{
    const result = await userModel.createUser(req.body);
    res.status(201).json({ message: "User registered successfully", userId: result });

  }
  catch(err){
    console.error("Register error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};


export const getMe = async (req, res) => {
 try{
    const user = await userModel.getUserById(req.user.id);
    res.status(200).json({ user });
 }
 catch(err){
    console.error("GetMe error:", err);
    res.status(500).json({ message: "Internal server error" });
 }
}

export const logoutUser = (req, res) => {
  res.clearCookie('token', { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: "strict" });
  res.status(200).json({ message: "Logout successful" });
};