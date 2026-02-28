import e from "express";
import db from "../config/db.js";

export const createRestaurant = async(data) => {
    const {name_res , open_time, close_time , status_res, phone, address, img_url , id_users} = data;
    const sql = "INSERT INTO restaurant (name_res, open_time, close_time, status_res , phone, address, img_url, id_users) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    updateRole(id_users);
    const [result] = await db.query(sql, [name_res , open_time, close_time , status_res, phone, address, img_url , id_users]);
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
    const {name_res , open_time, close_time , zone, phone, address, img_url , id_users , status_res} = data;
    const sql = `UPDATE restaurant SET name_res = COALESCE(?, name_res), 
                open_time = COALESCE(?, open_time), 
                close_time = COALESCE(?, close_time), 
                zone = COALESCE(?, zone), 
                phone = COALESCE(?, phone), 
                address = COALESCE(?, address), 
                img_url = COALESCE(?, img_url),
                status_res = COALESCE(?, status_res)
                WHERE id = ? AND id_users = ?`;
    const [result] = await db.query(sql, [name_res , open_time, close_time , zone, phone, address, img_url , status_res , id, id_users ]);
    return result;
}

export const getRestaurantsForUsers = async () => {
    const sql = "SELECT id, name_res, open_time, close_time, zone, phone, address, img_url, status_reg FROM restaurant WHERE status_reg = ?";
    const [rows] = await db.query(sql, ['success']);
    return rows;
};

export const getAllRestaurantsAdmin = async () => {
    const sql = "SELECT id, name_res, phone, address, status_reg, id_users, img_url, open_time, close_time FROM restaurant ORDER BY id DESC";
    const [rows] = await db.query(sql);
    return rows;
};

export const updateRestaurantStatus = async (id, status) => {
    const sql = "UPDATE restaurant SET status_reg = ? WHERE id = ?";
    const [result] = await db.query(sql, [status, id]);
    return result;
};