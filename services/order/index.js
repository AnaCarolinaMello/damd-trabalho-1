import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { registerWithGateway, unregisterFromGateway } from "./controllers/registry.controller.js";
import orderRoutes from "./routes/order.routes.js";

const app = express();

dotenv.config();

const gatewayUrl = process.env.GATEWAY_URL;

app.use(cors({
  origin: gatewayUrl
}));

app.use(express.json());

// Health check endpoint
app.get("/health", (_, res) => {
  res.status(200).json({
    status: "healthy",
    service: process.env.SERVICE_NAME,
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.use("/", orderRoutes);

app.listen(process.env.PORT, async () => {
  console.log(`Running on port ${process.env.PORT}`);
  
  await registerWithGateway();
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await unregisterFromGateway();
  process.exit(0);
});

process.on('SIGINT', async () => {
  await unregisterFromGateway();
  process.exit(0);
});