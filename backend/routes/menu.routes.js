import express from 'express';
import { authToken } from '../middleware/auth.middleware.js';
import { addMenuItem } from '../controllers/menu.controller.js';
import { editMenuItem } from '../controllers/menu.controller.js';
import uploadMenu from '../middleware/uploadImgMenu.middleware.js';

const router = express.Router();
router.post('/restaurant/:id/add',authToken,uploadMenu.single("image"),addMenuItem) ;  
router.put('/restaurant/:resId/edit/:menuId',authToken,uploadMenu.single("image"),editMenuItem) ;

export default router;