import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import orderRoutes from "./routes/order.routes.js";

const app = express();

dotenv.config();

app.use(cors());

app.use(express.json());

app.use("/order", orderRoutes);

app.listen(process.env.PORT, () => {
  console.log(`Server is running on port ${process.env.PORT}`);
});