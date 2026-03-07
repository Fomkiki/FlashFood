import db from "../config/db.js";
import bcrypt from "bcrypt";

export const createUser = async(data) => {
    const { username, password, email , phone , address } = data;
    const hashPass = await bcrypt.hash(password, 10);
    const sql = "INSERT INTO users (username, password, email, phone, address) VALUES (?, ?, ?, ?, ?)";
    const [result] = await db.query(sql, [username, hashPass, email, phone, address]);
    return result.insertId;
}

export const getUserByEmail = async(email) => {
    const sql = "SELECT * FROM users WHERE email = ?";
    const [row] = await db.query(sql, [email]);
    return row;
}

export const getUserById = async(id) => {
    const sql = "SELECT id, username, email, phone, address, role FROM users WHERE id = ?";
    const [row] = await db.query(sql, id);
    return row;
}

export const updateUser = async(id, username, address, phone) => {
    const sql = "UPDATE users SET username = ?, address = ?, phone = ? WHERE id = ?";
    const [result] = await db.query(sql, [username, address, phone, id]);
    return result;
}

export const getAllUsers = async () => {
    const sql = "SELECT id, username, email, phone, address, role FROM users ORDER BY id DESC";
    const [rows] = await db.query(sql);
    return rows;
}