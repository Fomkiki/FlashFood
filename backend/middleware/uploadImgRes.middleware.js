import multer from "multer";
import path from "path";

const storage = multer.diskStorage({
    destination:(req , file , cb) => {
        cb(null , "uploads/restaurants");
    },
    filename:(req , file , cb) => {
        const ext = path.extname(file.originalname);
        cb(null, "res_" + Date.now() + ext);

    }
});

const uploadRestaurant = multer({storage});

export default uploadRestaurant;