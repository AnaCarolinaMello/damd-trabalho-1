import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import {
  registerWithGateway,
  unregisterFromGateway,
} from "./controllers/registry.controller.js";
import notificationRoutes from "./routes/notification.routes.js";
import { return200 } from "./util/index.js";

const app = express();

dotenv.config();

const gatewayUrl = process.env.GATEWAY_URL;

app.use(
  cors({
    origin: gatewayUrl,
  })
);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Error handling middleware for body parsing
app.use((error, req, res, next) => {
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    console.error('Bad JSON:', error.message);
    return res.status(400).json({ error: 'Invalid JSON' });
  }
  next();
});

// Health check endpoint
app.get("/health", (_, res) => {
  return return200("healthy", res);
});

app.use("/", notificationRoutes);

app.listen(process.env.PORT, async () => {
  console.log(`Running on port ${process.env.PORT}`);

  await registerWithGateway();
});

// Graceful shutdown
process.on("SIGTERM", async () => {
  await unregisterFromGateway();
  process.exit(0);
});

process.on("SIGINT", async () => {
  await unregisterFromGateway();
  process.exit(0);
});
