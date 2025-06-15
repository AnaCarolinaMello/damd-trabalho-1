import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.routes.js";
import { registerWithGateway, unregisterFromGateway } from "./controllers/registry.controller.js";

const app = express();
app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);

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
