import db from "../config/db.js";

export const createMenu = async(data) => {
    try{
        const {id_res , name_menu, price, note , category, img_url , id_users } = data;
        const owner = await checkOwner(id_res, id_users);
        if(owner.length === 0){
            throw new Error("You are not the owner of this restaurant");
        }
        const sql = "INSERT INTO menu (id_res, name_menu, price, note, category, img_url) VALUES (?, ?, ?, ?, ?, ?)";
        const [result] = await db.query(sql,[id_res , name_menu, price, note , category, img_url]);
        return result.insertId;
    }
    catch(err){
        throw err;
    }
}

async function checkOwner(id_res, id_users){
    const sql = "SELECT * FROM restaurant WHERE id = ? AND id_users = ?";
   const [rows] = await db.query(sql, [id_res, id_users]);
   return rows;
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