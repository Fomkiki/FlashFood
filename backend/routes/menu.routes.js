import express from 'express';
import { authToken } from '../middleware/auth.middleware.js';
import { addMenuItem } from '../controllers/menu.controller.js';
import { editMenuItem } from '../controllers/menu.controller.js';
import { authRole } from '../middleware/authRole.middleware.js';
import uploadMenu from '../middleware/uploadImgMenu.middleware.js';
import { getAllMenu } from '../controllers/menu.controller.js';
import { getMenuById } from '../controllers/menu.controller.js';

const router = express.Router();
router.post('/restaurant/:id/add',authToken,uploadMenu.single("image"),authRole("restaurant"),addMenuItem) ;  
router.put('/restaurant/:resId/edit/:menuId',authToken,uploadMenu.single("image"),authRole("restaurant"),editMenuItem) ;
router.get('/restaurant/:id_res/menu',authToken,authRole("restaurant"),getAllMenu) ;
router.get('/restaurant/:id_res/menu/:id_menu',authToken,authRole("restaurant"),getMenuById) ;

export default router;