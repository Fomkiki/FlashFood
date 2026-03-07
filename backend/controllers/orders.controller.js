import * as orderModel from "../models/orders.model.js";

export const getOrdersMe = async (req, res) => {
    try{
        const orders = await orderModel.getOrders(req.user.id);
        res.status(200).json({ orders });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
}

export const getOrderById = async (req, res) => {
    try{
        const { id_orders } = req.params ;
        const order = await orderModel.getOrderById(id_orders);
        res.status(200).json({ order });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
}

export const getOrdersByRes = async (req, res) => {
    try{
        const { id_res } = req.params ;
        const orders = await orderModel.getOrdersByRes(id_res);
        res.status(200).json({ orders });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
}

export const paymentOrder = async (req, res) => {
    try{
        const { id_orders } = req.params ;
        const result = await orderModel.paymentOrder(id_orders, req.user.id);
        res.status(200).json({ message: "Order payment updated successfully" } , result);
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
}

export const updateOrderStatus = async (req, res) => {
    try{
        const { id_orders , status } = req.params;
    
        const result = await orderModel.updateOrderStatus(id_orders, status);
    
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Order not found' });
        }
    
        res.status(200).json({ message: 'Order status updated successfully' });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};