import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./routes/auth.routes.js";
import { return200 } from "./util/index.js";
import { registerWithGateway, unregisterFromGateway } from "./controllers/registry.controller.js";

const app = express();

dotenv.config();

const gatewayUrl = process.env.GATEWAY_URL;

app.use(cors({
  origin: gatewayUrl
}));

app.use(express.json());

app.get("/health", (_, res) => {
  return return200("healthy", res);
});

app.use('/', authRoutes);

const PORT = process.env.PORT;

app.listen(PORT, async () => {
  console.log(`Authentication service rodando na porta ${PORT}`);
  await registerWithGateway();
});

process.on("SIGTERM", async () => {
  await unregisterFromGateway();
  process.exit(0);
});

process.on("SIGINT", async () => {
  await unregisterFromGateway();
  process.exit(0);
});
