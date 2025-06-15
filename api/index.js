import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import registryRoutes from "./routes/registry.routes.js";
import { dynamicRouter } from "./middleware/gateway.js";
import { return404 } from "./util/index.js";

const app = express();

dotenv.config();

app.use(cors());
app.use(express.json());

app.use("/gateway", registryRoutes);

app.use("/", dynamicRouter);

app.use((req, res) => {
  return404(res, `Service or route ${req.originalUrl} not found`);
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Rrunning on port ${PORT}`);
  console.log(`Registry available at http://localhost:${PORT}/gateway/services`);
});