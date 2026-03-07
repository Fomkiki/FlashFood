import express from 'express' ;
import { authToken } from '../middleware/auth.middleware.js';
import { addCartItem } from '../controllers/cart.controller.js';
import { getCartItems } from '../controllers/cart.controller.js';
import { updateCartItem } from '../controllers/cart.controller.js';
import { deleteCartItem } from '../controllers/cart.controller.js';
import { checkoutCart } from '../controllers/cart.controller.js';

const router = express.Router() ;

router.post('/add/:menuId',authToken,addCartItem) ;
router.get('/items',authToken,getCartItems) ;
router.put('/items/:menuId',authToken,updateCartItem) ;
router.delete('/items/:menuId',authToken,deleteCartItem) ;
router.post('/checkout',authToken,checkoutCart) ;

export default router ;