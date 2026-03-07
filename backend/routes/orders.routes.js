import express from "express";
import { authToken } from "../middleware/auth.middleware.js";
import { getOrdersMe } from "../controllers/orders.controller.js";
import { getOrderById } from "../controllers/orders.controller.js";
import { getOrdersByRes } from "../controllers/orders.controller.js";
import { paymentOrder } from "../controllers/orders.controller.js";
import { updateOrderStatus } from "../controllers/orders.controller.js";



const router = express.Router();

router.get('/', authToken, getOrdersMe) ;
router.get('/detail/:id_orders', authToken, getOrderById) ;
router.get('/res/:id_res', authToken, getOrdersByRes) ;
router.put('/:id_orders/:status', authToken, updateOrderStatus) ;
router.put('/:id_orders/payment', authToken, paymentOrder) ;

export default router ;