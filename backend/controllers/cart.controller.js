import * as cartModel from "../models/cart.model.js";

export const addCartItem = async (req, res) => {
    try{
        const { menuId } = req.params ;
        const { amount } = req.body ;
        const data = {
            id_menu: menuId,
           amount:amount,
            id_users: req.user.id
        }
        const result = await cartModel.addCartItem(data);
        res.status(201).json({ message: "Cart item added successfully"});
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};

export const getCartItems = async (req,res) => {
    const result = await cartModel.getCartItems(req.user.id);
    res.status(200).json({ result });
}