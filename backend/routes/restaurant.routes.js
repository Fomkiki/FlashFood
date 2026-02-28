import express from 'express';
import uploadRestaurant from '../middleware/uploadImgRes.middleware.js';
import { registerRestaurant } from '../controllers/restaurant.controller.js';
import { getRestaurantById } from '../controllers/restaurant.controller.js';
import { getAllRestaurants } from '../controllers/restaurant.controller.js';
import { editRestaurant } from '../controllers/restaurant.controller.js';
import { getRestaurantsForUsers } from '../controllers/restaurant.controller.js';
import { getAllRestaurantsAdmin } from '../controllers/restaurant.controller.js';
import { updateRestaurantStatus } from '../controllers/restaurant.controller.js';
import { authToken } from '../middleware/auth.middleware.js';
import { authRole } from '../middleware/authRole.middleware.js';


const router = express.Router();
router.get('/user/all', getRestaurantsForUsers);
router.get('/admin/all', authToken, authRole('admin'), getAllRestaurantsAdmin);
router.post('/register',authToken,uploadRestaurant.single('image'), registerRestaurant)
router.get('/:id',authToken,authRole('restaurant'),getRestaurantById);
router.get('/',authToken,authRole('restaurant'),getAllRestaurants);
router.put('/:id',authToken,uploadRestaurant.single('image'),authRole('restaurant'), editRestaurant);
router.put('/admin/:id/status', authToken, authRole('admin'), updateRestaurantStatus);


export default router;
