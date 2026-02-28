import e from "express";
import * as restaurantModel from "../models/restaurant.model.js";

export const registerRestaurant = async (req, res) => {
    try{
        const data = {
            ...req.body,
            img_url: req.file ? req.file.path : null,
            id_users: req.user.id
        };
        const result = await restaurantModel.createRestaurant(data);
        res.status(201).json({ message: "Restaurant registered successfully", restaurantId: result });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};

export const getRestaurantById = async (req, res) => {
    try{
        const { id } = req.params;
        const id_users = req.user.id;
        const restaurant = await restaurantModel.getRestaurantById(id , id_users);
        res.status(200).json({ restaurant });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};

export const getAllRestaurants = async (req, res) => {
    try{
        const restaurants = await restaurantModel.getAllRestaurants(req.user.id);
        res.status(200).json({ restaurants });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
}


export const editRestaurant = async (req, res) => {
    try{
        const { id } = req.params;
        const data = {
            ...req.body,
            img_url: req.file ? req.file.path : null,
            id_users: req.user.id
        };
        const result = await restaurantModel.updateRestaurant(id, data);
        if(result.affectedRows === 0){
            return res.status(404).json({ message: "Restaurant not found or you are not the owner" });
        }
        res.status(200).json({ message: "Restaurant updated successfully" });

    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};

export const getRestaurantsForUsers = async (req, res) => {
    try{
        const restaurants = await restaurantModel.getRestaurantsForUsers();
        res.status(200).json({ restaurants });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};

export const getAllRestaurantsAdmin = async (req, res) => {
    try{
        const restaurants = await restaurantModel.getAllRestaurantsAdmin();
        res.status(200).json({ restaurants });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};

export const updateRestaurantStatus = async (req, res) => {
    try{
        const { id } = req.params;
        const { status } = req.body;

        if (!['waiting_approve', 'success','not_approve'].includes(status)) {
            return res.status(400).json({ message: 'Invalid status' });
        }
        
        const result = await restaurantModel.updateRestaurantStatus(id, status);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Restaurant not found' });
        }
        
        res.status(200).json({ message: 'Restaurant status updated successfully' });
    }
    catch(err){
        res.status(500).json({message: err.message});
    }
};