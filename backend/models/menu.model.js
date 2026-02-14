import db from "../config/db.js";

export const createMenu = async(data) => {
    const {id_res , name_menu, price, note , category, img_url  } = data;
    const sql = "INSERT INTO menu (id_res, name_menu, price, note, category, img_url) VALUES (?, ?, ?, ?, ?, ?)";
    const [result] = await db.query(sql,[id_res , name_menu, price, note , category, img_url]);
    return result.insertId;
}

export const updateMenu = async(data) => {

    const {id_res , menuId, name_menu, price, note , category, img_url  } = data;
    const sql = `UPDATE menu SET name_menu = COALESCE(?, name_menu), 
                price = COALESCE(?, price), 
                note = COALESCE(?, note), 
                category = COALESCE(?, category), 
                img_url = COALESCE(?, img_url) 
                WHERE id = ? AND id_res = ?`;
    const [result] = await db.query(sql,[name_menu, price, note , category, img_url , menuId, id_res]);
    return result;
}