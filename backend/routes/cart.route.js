import express from 'express' ;
import { authToken } from '../middleware/auth.middleware.js';
import { addCartItem } from '../controllers/cart.controller.js';
import { getCartItems } from '../controllers/cart.controller.js';

const router = express.Router() ;

router.post('/add/:menuId',authToken,addCartItem) ;
router.get('/items',authToken,getCartItems) ;

export default router ;