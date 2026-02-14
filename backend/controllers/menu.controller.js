import * as menuModel from '../models/menu.model.js';

export const addMenuItem = async (req,res) => {
    try{
        const data = {
            ...req.body,
            id_res: req.params.id,
            id_users: req.user.id,
            img_url: req.file ? req.file.path : null
        }
        const result = await menuModel.createMenu(data);
        res.status(201).json({ message: "Menu item added successfully", menuItemId: result });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
}

export const editMenuItem = async (req,res) => {
    try{
        const {resId , menuId} = req.params;
        const data = {
            ...req.body,
            id_res: resId,
            menuId,
            img_url: req.file ? req.file.path : null,
        }
        const result = await menuModel.updateMenu(data);
        if(result.affectedRows === 0){
            return res.status(404).json({ message: "Menu item not found or you are not the owner" });
        }
        res.status(200).json({ message: "Menu item updated successfully" });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }

}