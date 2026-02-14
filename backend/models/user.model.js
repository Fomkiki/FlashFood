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
    const [row] = await db.query(sql, [id]);
    return row;
}