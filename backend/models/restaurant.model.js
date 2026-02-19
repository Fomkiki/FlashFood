import e from "express";
import db from "../config/db.js";

export const createRestaurant = async(data) => {
    const {name_res , open_time, close_time , zone, phone, address, img_url , id_users} = data;
    const sql = "INSERT INTO restaurant (name_res, open_time, close_time, zone, phone, address, img_url, id_users) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    updateRole(id_users);
    const [result] = await db.query(sql, [name_res , open_time, close_time , zone, phone, address, img_url , id_users]);
    return result.insertId;
};

function updateRole(id_users){
    const sql = "UPDATE users SET role = 'restaurant' WHERE id = ?";
    db.query(sql, [id_users]);
}

export const getRestaurantById = async (id, id_users) => {
    const sql = "SELECT * FROM restaurant WHERE id = ? AND id_users = ?";
    const [rows] = await db.query(sql, [id, id_users]);
    return rows[0];
};

export const getAllRestaurants = async (id_users) => {
    const sql = "SELECT * FROM restaurant WHERE id_users = ? AND  status_reg = ? " ;
    const [rows] = await db.query(sql, [id_users, 'success']);
    return rows;
}



export const updateRestaurant = async (id, data) => {
    const {name_res , open_time, close_time , zone, phone, address, img_url , id_users} = data;
    const sql = `UPDATE restaurant SET name_res = COALESCE(?, name_res), 
                open_time = COALESCE(?, open_time), 
                close_time = COALESCE(?, close_time), 
                zone = COALESCE(?, zone), 
                phone = COALESCE(?, phone), 
                address = COALESCE(?, address), 
                img_url = COALESCE(?, img_url) 
                WHERE id = ? AND id_users = ?`;
    const [result] = await db.query(sql, [name_res , open_time, close_time , zone, phone, address, img_url , id, id_users]);
    return result;
}