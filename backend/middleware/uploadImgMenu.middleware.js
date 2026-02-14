import multer from "multer";
import path from "path";

const storage = multer.diskStorage({
    destination:(req , file , cb) => {
        cb(null , "uploads/menu");
    },
    filename:(req , file , cb) => {
        const ext = path.extname(file.originalname);
        cb(null, "menu_" + Date.now() + ext);

    }
});

const uploadMenu = multer({storage});

export default uploadMenu;