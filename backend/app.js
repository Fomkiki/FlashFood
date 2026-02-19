import express from "express";
import cors from "cors";
import authRouter from "./routes/auth.routes.js";
import resterantRouter from "./routes/restaurant.routes.js";
import cookieParser from "cookie-parser";
import menuRouter from "./routes/menu.routes.js";
import cartRouter from "./routes/cart.route.js";
import db from "./config/db.js";
const app = express();


app.use(cors());
app.use(cookieParser());
app.use(express.json());
app.use("/uploads", express.static("uploads"));



app.use("/api/auth", authRouter);
app.use("/api/restaurant", resterantRouter);
app.use("/api", menuRouter);
app.use("/api/cart", cartRouter);



async function DBConnection() {
  try{
    await db.execute("SELECT 1");
    console.log("Database connection successful");
  }
  catch (error) {
    console.error("Database connection failed:", error);
  }
}


app.listen(5000, () => {
  console.log("Server running on port 5000");
  DBConnection();
});
